import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)
    @State private var autoUpdate = (NSApp.delegate as? AppDelegate)?.updaterController.updater.automaticallyChecksForUpdates ?? true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.headline)

            Divider()

            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { enabled in
                    if enabled {
                        try? SMAppService.mainApp.register()
                    } else {
                        try? SMAppService.mainApp.unregister()
                    }
                }

            Toggle("Auto-check for Updates", isOn: $autoUpdate)
                .onChange(of: autoUpdate) { enabled in
                    (NSApp.delegate as? AppDelegate)?.updaterController.updater.automaticallyChecksForUpdates = enabled
                }

            Divider()

            Button("Check for Updates…") {
                (NSApp.delegate as? AppDelegate)?.updaterController.checkForUpdates(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
        }
        .padding(16)
        .frame(width: 220)
    }
}
