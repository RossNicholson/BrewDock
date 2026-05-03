import AppKit
import SwiftUI
import Sparkle

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var panel: NSPanel!
    private var eventMonitor: Any?
    let brewService = BrewService()
    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mug.fill", accessibilityDescription: "BrewDock")
            button.action = #selector(togglePanel)
            button.target = self
        }

        setupPanel()
    }

    private func setupPanel() {
        let content = MenuBarView().environmentObject(brewService)
        let hostingView = NSHostingView(rootView: content)
        hostingView.autoresizingMask = [.width, .height]

        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 520),
            styleMask: [.resizable, .titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hostingView
        panel.delegate = self
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.minSize = NSSize(width: 280, height: 300)
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
    }

    @objc func togglePanel() {
        if panel.isVisible { closePanel() } else { openPanel() }
    }

    private func openPanel() {
        positionPanel()
        panel.makeKeyAndOrderFront(nil)

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePanel()
        }
    }

    func closePanel() {
        panel.orderOut(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func positionPanel() {
        guard let button = statusItem.button,
              let buttonWindow = button.window else { return }

        let buttonRect = button.convert(button.bounds, to: nil)
        let screenRect = buttonWindow.convertToScreen(buttonRect)
        guard let screen = buttonWindow.screen ?? NSScreen.main ?? NSScreen.screens.first else { return }

        var x = screenRect.midX - panel.frame.width / 2
        let y = screenRect.minY - panel.frame.height

        x = min(max(x, screen.visibleFrame.minX + 4),
                screen.visibleFrame.maxX - panel.frame.width - 4)

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    func windowDidResignKey(_ notification: Notification) {
        closePanel()
    }
}
