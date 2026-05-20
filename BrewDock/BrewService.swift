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
    private var lastRefresh: Date = .distantPast
    /// Resolved cask token → app bundle path. `brew info` is slow over many casks,
    /// so we only query it for casks we haven't already resolved.
    private var appPathCache: [String: String] = [:]
    private static let refreshTTL: TimeInterval = 30

    func refresh(force: Bool = false) async {
        guard !isLoading else { return }
        // The panel triggers refresh on every open; skip if we refreshed recently
        // so reopening feels instant. The manual refresh button passes force: true.
        if !force, Date().timeIntervalSince(lastRefresh) < Self.refreshTTL { return }
        isLoading = true
        defer { isLoading = false }

        async let caskResult    = brew(["list", "--cask", "--versions"])
        async let formulaResult = brew(["list", "--formula", "--versions"])
        async let outdatedResult = brew(["outdated", "--quiet"])

        let (caskRes, formulaRes, outdatedRes) = await (caskResult, formulaResult, outdatedResult)

        outdatedNames = Set(outdatedRes.output.lines)
        var parsedCasks = BrewParse.packages(from: caskRes.output, type: .cask, outdated: outdatedNames)

        if !parsedCasks.isEmpty {
            await resolveAppPaths(forCaskNames: parsedCasks.map(\.name))
            parsedCasks = parsedCasks.map { pkg in
                var p = pkg
                if let path = appPathCache[pkg.name] {
                    p.resolvedAppPath = path
                    p.appIcon = NSWorkspace.shared.icon(forFile: path)
                }
                return p
            }
        }

        self.casks = parsedCasks
        self.formulae = BrewParse.packages(from: formulaRes.output, type: .formula, outdated: outdatedNames)
        lastRefresh = Date()
    }

    /// Populate `appPathCache` for any cask tokens we don't yet know, by asking
    /// `brew info` only about the unknown ones and resolving them against disk.
    private func resolveAppPaths(forCaskNames names: [String]) async {
        let unknown = names.filter { appPathCache[$0] == nil }
        guard !unknown.isEmpty else { return }
        let infoRes = await brew(["info", "--json=v2", "--cask"] + unknown)
        for (token, appNames) in BrewParse.caskAppNames(fromJSON: infoRes.output) {
            let candidates = appNames.flatMap { name in
                ["/Applications/\(name)",
                 NSString(string: "~/Applications/\(name)").expandingTildeInPath]
            }
            if let path = candidates.first(where: { FileManager.default.fileExists(atPath: $0) }) {
                appPathCache[token] = path
            }
        }
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

    // Called when the user explicitly clicks "Check for Updates" — runs brew update first.
    // `showProgress: false` lets the periodic background timer refresh quietly.
    func checkSelfUpdate(showProgress: Bool = true) async {
        if showProgress { isCheckingSelfUpdate = true }
        defer { if showProgress { isCheckingSelfUpdate = false } }
        _ = await brew(["update"], timeout: 60)
        let result = await brew(["outdated", "--cask", "brewdock"])
        selfUpdateAvailable = result.output.lines.contains { $0.trimmingCharacters(in: .whitespaces) == "brewdock" }
    }

    func updateSelf() async {
        isUpdatingSelf = true
        // An app can't replace itself from a `brew` subprocess it has to quit first:
        // the cask's `quit:` directive kills us, and the child brew dies mid-upgrade
        // (its stdout pipe breaks), leaving the app closed and un-updated. Hand the
        // work to a detached helper that outlives us, then quit so it can take over.
        guard launchDetachedSelfUpdater() else {
            isUpdatingSelf = false
            lastError = "Couldn't start the updater."
            return
        }
        NSApp.terminate(nil)
    }

    /// Writes a self-update script and launches it fully detached (its own null
    /// stdio, reparented to launchd) so it survives this process quitting. The
    /// script waits for us to exit, runs `brew upgrade --cask brewdock`, then
    /// relaunches the freshly installed build.
    private func launchDetachedSelfUpdater() -> Bool {
        let fm = FileManager.default
        guard let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return false
        }
        let dir = support.appendingPathComponent("BrewDock", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        let scriptURL = dir.appendingPathComponent("self-update.sh")
        let logURL = dir.appendingPathComponent("self-update.log")

        let pid = ProcessInfo.processInfo.processIdentifier
        let appPath = Bundle.main.bundlePath
        let bundleID = Bundle.main.bundleIdentifier ?? "com.rossnicholson.BrewDock"

        // Note: `$(...)`, `$LOG`, `$status` are literal shell — only `\(...)` is
        // interpolated by Swift. Paths are quoted to tolerate spaces.
        let script = """
        #!/bin/sh
        export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        LOG="\(logURL.path)"
        : > "$LOG"
        echo "[$(date)] waiting for BrewDock (pid \(pid)) to quit" >> "$LOG"
        for i in $(seq 1 60); do
            kill -0 \(pid) 2>/dev/null || break
            sleep 0.5
        done
        echo "[$(date)] running brew upgrade --cask brewdock" >> "$LOG"
        "\(brewPath)" upgrade --cask brewdock >> "$LOG" 2>&1
        status=$?
        echo "[$(date)] brew exited with status $status" >> "$LOG"
        if [ "$status" -eq 0 ]; then
            open -b "\(bundleID)" || open "\(appPath)"
        else
            osascript -e 'display notification "Update failed — see ~/Library/Application Support/BrewDock/self-update.log" with title "BrewDock"' >/dev/null 2>&1 || true
        fi
        """

        do {
            try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        } catch {
            return false
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = [scriptURL.path]
        // Detached stdio: a broken pipe to this (dying) process must not abort the helper.
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            return true
        } catch {
            return false
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
        let result = await brew(["services", "list", "--json"])
        services = BrewParse.services(fromJSON: result.output)
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

}

private let brewPath: String = {
    let candidates = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
    return candidates.first { FileManager.default.fileExists(atPath: $0) } ?? "/opt/homebrew/bin/brew"
}()

private struct BrewResult {
    let output: String
    let exitCode: Int32
}

/// Deterministic environment for every `brew` invocation. A Finder-launched app
/// inherits a minimal environment, so we set an explicit PATH (incl. the brew
/// prefix, for the git/curl/etc. brew shells out to), HOME, a UTF-8 locale, and
/// disable implicit auto-update + hint noise so output stays parseable.
private let brewEnvironment: [String: String] = {
    var env = ProcessInfo.processInfo.environment
    let prefix = (brewPath as NSString).deletingLastPathComponent   // e.g. /opt/homebrew/bin
    let base = "\(prefix):/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    let inherited = env["PATH"].map { ":\($0)" } ?? ""
    env["PATH"] = base + inherited
    if env["HOME"] == nil { env["HOME"] = NSHomeDirectory() }
    if env["LANG"] == nil { env["LANG"] = "en_US.UTF-8" }
    env["HOMEBREW_NO_AUTO_UPDATE"] = "1"   // explicit `brew update` still works
    env["HOMEBREW_NO_ENV_HINTS"] = "1"
    return env
}()

private func brew(_ args: [String], timeout: TimeInterval = 30) async -> BrewResult {
    await withCheckedContinuation { continuation in
        let process = Process()
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = args
        process.environment = brewEnvironment
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

extension String {
    var lines: [String] {
        split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }
}
