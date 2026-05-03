import SwiftUI

struct ServiceRowView: View {
    let service: HomebrewService
    @EnvironmentObject var brewService: BrewService
    @State private var isHovered = false

    private var isManaging: Bool {
        brewService.managingServices.contains(service.name)
    }

    var body: some View {
        HStack(spacing: 10) {
            statusIcon
            serviceInfo
            Spacer()
            actions
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color.primary.opacity(0.05) : .clear)
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
    }

    private var statusIcon: some View {
        Image(systemName: service.status.symbol)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(service.status.color)
            .frame(width: 28, height: 28)
            .background(service.status.color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var serviceInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(service.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            Text(service.status.displayLabel)
                .font(.caption2)
                .foregroundStyle(service.status.color.opacity(0.85))
        }
    }

    @ViewBuilder
    private var actions: some View {
        if isManaging {
            ProgressView()
                .scaleEffect(0.6)
                .frame(width: 50, height: 24)
        } else if isHovered {
            HStack(spacing: 4) {
                switch service.status {
                case .started:
                    actionButton("stop.fill", color: .red, help: "Stop") {
                        Task { await brewService.stopService(service) }
                    }
                    actionButton("arrow.triangle.2.circlepath", color: .orange, help: "Restart") {
                        Task { await brewService.restartService(service) }
                    }
                case .stopped, .error, .none:
                    actionButton("play.fill", color: .green, help: "Start") {
                        Task { await brewService.startService(service) }
                    }
                    if service.status == .error {
                        actionButton("arrow.triangle.2.circlepath", color: .orange, help: "Restart") {
                            Task { await brewService.restartService(service) }
                        }
                    }
                case .unknown:
                    EmptyView()
                }
            }
            .transition(.opacity)
        }
    }

    private func actionButton(_ symbol: String, color: Color, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
