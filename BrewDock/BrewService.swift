import Foundation
import AppKit
import SwiftUI

struct BrewPackage: Identifiable, Hashable {
    var id: String { "\(type):\(name)" }
    let name: String
    let version: String
    let type: PackageType
    var isOutdated: Bool = false
    var resolvedAppPath: String? = nil

    enum PackageType {
        case cask, formula
    }

    // True for casks that install only a CLI binary, no .app bundle
    var isCLIOnly: Bool {
        type == .cask && resolvedAppPath == nil
    }

    var appURL: URL? {
        resolvedAppPath.map { URL(fileURLWithPath: $0) }
    }

    var formulaIcon: FormulaIcon? {
        FormulaIcons.icon(for: name)
    }

    var appIcon: NSImage? {
        appURL.map { NSWorkspace.shared.icon(forFile: $0.path) }
    }

    var runningApplication: NSRunningApplication? {
        guard type == .cask, let appPath = resolvedAppPath else { return nil }
        return NSWorkspace.shared.runningApplications.first {
            $0.bundleURL?.path == appPath
        }
    }
}

struct HomebrewService: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let status: Status
    let user: String

    enum Status: String {
        case started, stopped, error, none = "none", unknown

        var color: Color {
            switch self {
            case .started: return .green
            case .error: return .red
            case .stopped, .none: return Color(nsColor: .secondaryLabelColor)
            case .unknown: return .orange
            }
        }

        var symbol: String {
            switch self {
            case .started: return "circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .stopped: return "circle"
            case .none: return "minus.circle"
            case .unknown: return "questionmark.circle"
            }
        }

        var displayLabel: String {
            self == .none ? "not started" : rawValue
        }
    }
}

@MainActor
class BrewService: ObservableObject {
    @Published var casks: [BrewPackage] = []
    @Published var formulae: [BrewPackage] = []
    @Published var services: [HomebrewService] = []
    @Published var isLoading = false
    @Published var isLoadingServices = false
    @Published var updatingPackages: Set<String> = []
    @Published var removingPackages: Set<String> = []
    @Published var installingPackages: Set<String> = []
    @Published var managingServices: Set<String> = []
    private var outdatedNames: Set<String> = []

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        async let caskOutput = brew(["list", "--cask", "--versions"])
        async let formulaOutput = brew(["list", "--formula", "--versions"])
        async let outdatedOutput = brew(["outdated", "--quiet"])

        let (caskRaw, formulaRaw, outdatedRaw) = await (caskOutput, formulaOutput, outdatedOutput)

        outdatedNames = Set(outdatedRaw.lines)
        var parsedCasks = parse(caskRaw, type: .cask)

        // Enrich casks with real .app paths from brew info
        if !parsedCasks.isEmpty {
            let names = parsedCasks.map(\.name)
            let infoJSON = await brew(["info", "--json=v2", "--cask"] + names)
            let appPaths = parseAppPaths(from: infoJSON)
            parsedCasks = parsedCasks.map { pkg in
                var updated = pkg
                updated.resolvedAppPath = appPaths[pkg.name]
                return updated
            }
        }

        self.casks = parsedCasks
        self.formulae = parse(formulaRaw, type: .formula)
    }

    func upgrade(_ package: BrewPackage) async {
        updatingPackages.insert(package.name)
        defer { updatingPackages.remove(package.name) }
        let typeFlag = package.type == .cask ? "--cask" : "--formula"
        _ = await brew(["upgrade", typeFlag, package.name])
        await refresh()
    }

    func install(_ package: DiscoverPackage) async {
        installingPackages.insert(package.id)
        defer { installingPackages.remove(package.id) }
        let typeFlag = package.type == .cask ? "--cask" : "--formula"
        _ = await brew(["install", typeFlag, package.id])
        await refresh()
    }

    func uninstall(_ package: BrewPackage) async {
        removingPackages.insert(package.name)
        defer { removingPackages.remove(package.name) }
        let typeFlag = package.type == .cask ? "--cask" : "--formula"
        _ = await brew(["uninstall", typeFlag, package.name])
        await refresh()
    }

    func upgradeAll() async {
        isLoading = true
        _ = await brew(["upgrade"])
        await refresh()
    }

    func refreshServices() async {
        guard !isLoadingServices else { return }
        isLoadingServices = true
        defer { isLoadingServices = false }
        let output = await brew(["services", "list"])
        services = parseServices(output)
    }

    func startService(_ service: HomebrewService) async {
        await manageService(service, command: "start")
    }

    func stopService(_ service: HomebrewService) async {
        await manageService(service, command: "stop")
    }

    func restartService(_ service: HomebrewService) async {
        await manageService(service, command: "restart")
    }

    private func manageService(_ service: HomebrewService, command: String) async {
        managingServices.insert(service.name)
        defer { managingServices.remove(service.name) }
        _ = await brew(["services", command, service.name])
        await refreshServices()
    }

    private func parseServices(_ output: String) -> [HomebrewService] {
        var lines = output.lines
        if lines.first?.split(separator: " ").first?.lowercased() == "name" {
            lines.removeFirst()
        }
        return lines.compactMap { line in
            let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            guard parts.count >= 2 else { return nil }
            let status = HomebrewService.Status(rawValue: parts[1]) ?? .unknown
            let user = parts.count > 2 ? parts[2] : ""
            return HomebrewService(name: parts[0], status: status, user: user)
        }
    }

    private func parse(_ output: String, type: BrewPackage.PackageType) -> [BrewPackage] {
        output.lines.compactMap { line in
            let parts = line.split(separator: " ", maxSplits: 1)
            guard let name = parts.first.map(String.init) else { return nil }
            let version = parts.count > 1 ? String(parts[1]) : ""
            return BrewPackage(
                name: name,
                version: version,
                type: type,
                isOutdated: outdatedNames.contains(name)
            )
        }
    }

    // Parses `brew info --json=v2 --cask` output into a token → app path map
    private func parseAppPaths(from json: String) -> [String: String] {
        guard
            let data = json.data(using: .utf8),
            let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let casks = obj["casks"] as? [[String: Any]]
        else { return [:] }

        var result: [String: String] = [:]
        for cask in casks {
            guard
                let token = cask["token"] as? String,
                let artifacts = cask["artifacts"] as? [[String: Any]]
            else { continue }

            for artifact in artifacts {
                guard let apps = artifact["app"] as? [String], let appName = apps.first else { continue }
                let candidates = [
                    "/Applications/\(appName)",
                    (NSString(string: "~/Applications/\(appName)").expandingTildeInPath)
                ]
                if let path = candidates.first(where: { FileManager.default.fileExists(atPath: $0) }) {
                    result[token] = path
                    break
                }
            }
        }
        return result
    }
}

private let brewPath: String = {
    let candidates = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
    return candidates.first { FileManager.default.fileExists(atPath: $0) } ?? "/opt/homebrew/bin/brew"
}()

private func brew(_ args: [String]) async -> String {
    await withCheckedContinuation { continuation in
        let process = Process()
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        process.terminationHandler = { _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            continuation.resume(returning: String(data: data, encoding: .utf8) ?? "")
        }
        do {
            try process.run()
        } catch {
            continuation.resume(returning: "")
        }
    }
}

private extension String {
    var lines: [String] {
        split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }
}
