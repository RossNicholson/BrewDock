import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)
    @State private var autoUpdate = (NSApp.delegate as? AppDelegate)?.updaterController.updater.automaticallyChecksForUpdates ?? true

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "gearshape")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text("Settings")
                    .font(.title3).fontWeight(.semibold)
            }

            Divider()

            VStack(alignment: .leading, spacing: 14) {
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
        }
        .padding(20)
        .frame(width: 240)
    }
}
