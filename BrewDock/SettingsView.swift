import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var brewService: BrewService
    @State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)

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

                Divider()

                if brewService.selfUpdateAvailable {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("A BrewDock update is available.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button(brewService.isUpdatingSelf ? "Updating…" : "Update BrewDock…") {
                            Task { await brewService.updateSelf() }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.accentColor)
                        .disabled(brewService.isUpdatingSelf)
                    }
                } else {
                    Button(brewService.isCheckingSelfUpdate ? "Checking…" : "Check for Updates…") {
                        Task { await brewService.checkSelfUpdate() }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .disabled(brewService.isCheckingSelfUpdate)
                }
            }
        }
        .padding(20)
        .frame(width: 240)
    }
}
