import Foundation
import AppKit
import SwiftUI

struct BrewPackage: Identifiable {
    var id: String { "\(type):\(name)" }
    let name: String
    let version: String
    let type: PackageType
    var isOutdated: Bool = false
    var resolvedAppPath: String? = nil
    var appIcon: NSImage? = nil  // cached once during refresh — not recomputed on every redraw

    enum PackageType {
        case cask, formula
    }

    var isCLIOnly: Bool {
        type == .cask && resolvedAppPath == nil
    }

    var appURL: URL? {
        resolvedAppPath.map { URL(fileURLWithPath: $0) }
    }

    var formulaIcon: FormulaIcon? {
        FormulaIcons.icon(for: name)
    }

    var runningApplication: NSRunningApplication? {
        guard type == .cask, let appPath = resolvedAppPath else { return nil }
        return NSWorkspace.shared.runningApplications.first {
            $0.bundleURL?.path == appPath
        }
    }
}

// NSImage is not Hashable — provide manual conformance that ignores the icon
extension BrewPackage: Hashable {
    static func == (lhs: BrewPackage, rhs: BrewPackage) -> Bool {
        lhs.id == rhs.id && lhs.isOutdated == rhs.isOutdated
    }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
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
    @Published var lastError: String? = nil
    @Published var isBrewfileWorking = false
    @Published var selfUpdateAvailable: Bool = false
    @Published var isCheckingSelfUpdate: Bool = false
    @Published var isUpdatingSelf: Bool = false
    private var outdatedNames: Set<String> = []

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        async let caskResult    = brew(["list", "--cask", "--versions"])
        async let formulaResult = brew(["list", "--formula", "--versions"])
        async let outdatedResult = brew(["outdated", "--quiet"])

        let (caskRes, formulaRes, outdatedRes) = await (caskResult, formulaResult, outdatedResult)

        outdatedNames = Set(outdatedRes.output.lines)
        var parsedCasks = parse(caskRes.output, type: .cask)

        if !parsedCasks.isEmpty {
            let names = parsedCasks.map(\.name)
            let infoRes = await brew(["info", "--json=v2", "--cask"] + names)
            let appPaths = parseAppPaths(from: infoRes.output)
            parsedCasks = parsedCasks.map { pkg in
                var p = pkg
                if let path = appPaths[pkg.name] {
                    p.resolvedAppPath = path
                    p.appIcon = NSWorkspace.shared.icon(forFile: path)
                }
                return p
            }
        }

        self.casks = parsedCasks
        self.formulae = parse(formulaRes.output, type: .formula)
    }

    func upgrade(_ package: BrewPackage) async {
        updatingPackages.insert(package.name)
        defer { updatingPackages.remove(package.name) }
        let flag = package.type == .cask ? "--cask" : "--formula"
        let result = await brew(["upgrade", flag, package.name])
        if result.exitCode != 0 { lastError = "Failed to update \(package.name)" }
        await refresh()
    }

    func install(_ package: DiscoverPackage) async {
        installingPackages.insert(package.id)
        defer { installingPackages.remove(package.id) }
        let flag = package.type == .cask ? "--cask" : "--formula"
        let result = await brew(["install", flag, package.id])
        if result.exitCode != 0 { lastError = "Failed to install \(package.displayName)" }
        await refresh()
    }

    func uninstall(_ package: BrewPackage) async {
        removingPackages.insert(package.name)
        defer { removingPackages.remove(package.name) }
        let flag = package.type == .cask ? "--cask" : "--formula"
        let result = await brew(["uninstall", flag, package.name])
        if result.exitCode != 0 { lastError = "Failed to uninstall \(package.name)" }
        await refresh()
    }

    // Called on launch — quick check against local cache, no network fetch
    func checkSelfUpdateSilent() async {
        let result = await brew(["outdated", "--cask", "brewdock"])
        selfUpdateAvailable = result.output.lines.contains { $0.trimmingCharacters(in: .whitespaces) == "brewdock" }
    }

    // Called when the user explicitly clicks "Check for Updates" — runs brew update first
    func checkSelfUpdate() async {
        isCheckingSelfUpdate = true
        defer { isCheckingSelfUpdate = false }
        await brew(["update"], timeout: 60)
        let result = await brew(["outdated", "--cask", "brewdock"])
        selfUpdateAvailable = result.output.lines.contains { $0.trimmingCharacters(in: .whitespaces) == "brewdock" }
    }

    func updateSelf() async {
        isUpdatingSelf = true
        let result = await brew(["upgrade", "--cask", "brewdock"], timeout: 120)
        if result.exitCode == 0 {
            NSApp.terminate(nil)
        } else {
            isUpdatingSelf = false
            lastError = "Failed to update BrewDock"
        }
    }

    func upgradeAll() async {
        // Bug fix: do NOT set isLoading = true here — refresh() owns that flag.
        // Setting it here caused refresh()'s guard to short-circuit, leaving the list stale.
        let result = await brew(["upgrade"])
        if result.exitCode != 0 { lastError = "Some updates failed" }
        await refresh()
    }

    func brewfileDump(to path: String) async -> (success: Bool, message: String) {
        isBrewfileWorking = true
        defer { isBrewfileWorking = false }
        let result = await brew(["bundle", "dump", "--file=\(path)", "--force"])
        guard result.exitCode == 0 else { return (false, "Failed to export Brewfile.") }
        return (true, "Brewfile saved.")
    }

    func brewfileInstall(from path: String) async -> (success: Bool, message: String) {
        isBrewfileWorking = true
        defer { isBrewfileWorking = false }
        let result = await brew(["bundle", "install", "--file=\(path)"], timeout: 600)
        if result.exitCode == 0 { await refresh() }
        guard result.exitCode == 0 else { return (false, "Some packages failed to install.") }
        return (true, "All packages installed.")
    }

    func brewfileCheck(at path: String) async -> (success: Bool, message: String) {
        isBrewfileWorking = true
        defer { isBrewfileWorking = false }
        let result = await brew(["bundle", "check", "--file=\(path)", "--verbose"])
        if result.exitCode == 0 { return (true, "All packages are installed.") }
        let missing = result.output.lines.filter { $0.hasPrefix("x ") }.map { String($0.dropFirst(2)) }
        return (false, missing.isEmpty ? "Some packages are missing." : "Missing: \(missing.joined(separator: ", "))")
    }

    func brewfileCleanupPreview(at path: String) async -> [String] {
        isBrewfileWorking = true
        defer { isBrewfileWorking = false }
        let result = await brew(["bundle", "cleanup", "--file=\(path)"])
        return result.output.lines.filter { !$0.isEmpty }
    }

    func brewfileCleanup(at path: String) async -> (success: Bool, message: String) {
        isBrewfileWorking = true
        defer { isBrewfileWorking = false }
        let result = await brew(["bundle", "cleanup", "--file=\(path)", "--force"])
        if result.exitCode == 0 { await refresh() }
        guard result.exitCode == 0 else { return (false, "Cleanup failed.") }
        return (true, "Cleanup complete.")
    }

    func refreshServices() async {
        guard !isLoadingServices else { return }
        isLoadingServices = true
        defer { isLoadingServices = false }
        let result = await brew(["services", "list"])
        services = parseServices(result.output)
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
        let result = await brew(["services", command, service.name])
        if result.exitCode != 0 { lastError = "Failed to \(command) \(service.name)" }
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

private struct BrewResult {
    let output: String
    let exitCode: Int32
}

private func brew(_ args: [String], timeout: TimeInterval = 30) async -> BrewResult {
    await withCheckedContinuation { continuation in
        let process = Process()
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice  // prevent stderr buffer-fill hang

        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            if process.isRunning { process.terminate() }
        }

        process.terminationHandler = { p in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            continuation.resume(returning: BrewResult(output: output, exitCode: p.terminationStatus))
        }
        do {
            try process.run()
        } catch {
            continuation.resume(returning: BrewResult(output: "", exitCode: 1))
        }
    }
}

private extension String {
    var lines: [String] {
        split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }
}
