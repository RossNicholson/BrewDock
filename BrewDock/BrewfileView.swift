import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct BrewfileView: View {
    @EnvironmentObject var brewService: BrewService
    @State private var statusMessage: String? = nil
    @State private var statusIsSuccess = false
    @State private var cleanupPreview: [String] = []
    @State private var showCleanupConfirm = false
    @State private var pendingCleanupPath: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
                Text("Brewfile")
                    .font(.title3).fontWeight(.semibold)
                Text("Backup and restore your Homebrew setup")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Divider()

            VStack(spacing: 10) {
                brewfileAction(
                    title: "Export",
                    description: "Save your installed packages to a Brewfile",
                    icon: "arrow.up.doc", color: .blue
                ) { exportBrewfile() }

                brewfileAction(
                    title: "Install",
                    description: "Install all packages listed in a Brewfile",
                    icon: "arrow.down.doc", color: .green
                ) { installFromBrewfile() }

                brewfileAction(
                    title: "What's Missing?",
                    description: "Check which packages in a Brewfile you don't have yet",
                    icon: "questionmark.circle", color: .orange
                ) { checkBrewfile() }

                brewfileAction(
                    title: "Remove Unlisted",
                    description: "Remove packages not in your Brewfile",
                    icon: "trash", color: .red
                ) { previewCleanup() }
            }
            .disabled(brewService.isBrewfileWorking)

            if brewService.isBrewfileWorking {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7)
                    Text("Working…").font(.caption).foregroundStyle(.secondary)
                }
            }

            if let msg = statusMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(statusIsSuccess ? .green : .red)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(width: 240)
        .confirmationDialog(
            "Remove \(cleanupPreview.count) package\(cleanupPreview.count == 1 ? "" : "s")?",
            isPresented: $showCleanupConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                guard let path = pendingCleanupPath else { return }
                Task {
                    let (ok, msg) = await brewService.brewfileCleanup(at: path)
                    statusIsSuccess = ok
                    statusMessage = msg
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(cleanupPreview.joined(separator: "\n"))
        }
    }

    private func brewfileAction(title: String, description: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
        }
        .buttonStyle(.plain)
        .liquidGlassInteractive(in: RoundedRectangle(cornerRadius: 8))
    }

    private func exportBrewfile() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Brewfile"
        panel.allowedContentTypes = [.plainText]
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        statusMessage = nil
        Task {
            let (ok, msg) = await brewService.brewfileDump(to: url.path)
            statusIsSuccess = ok
            statusMessage = msg
        }
    }

    private func installFromBrewfile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.plainText, .data]
        panel.message = "Choose a Brewfile to install from"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        statusMessage = nil
        Task {
            let (ok, msg) = await brewService.brewfileInstall(from: url.path)
            statusIsSuccess = ok
            statusMessage = msg
        }
    }

    private func checkBrewfile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.plainText, .data]
        panel.message = "Choose a Brewfile to check"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        statusMessage = nil
        Task {
            let (ok, msg) = await brewService.brewfileCheck(at: url.path)
            statusIsSuccess = ok
            statusMessage = msg
        }
    }

    private func previewCleanup() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.plainText, .data]
        panel.message = "Choose a Brewfile to clean up against"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        statusMessage = nil
        Task {
            let packages = await brewService.brewfileCleanupPreview(at: url.path)
            if packages.isEmpty {
                statusIsSuccess = true
                statusMessage = "Nothing to clean up."
            } else {
                cleanupPreview = packages
                pendingCleanupPath = url.path
                showCleanupConfirm = true
            }
        }
    }
}
