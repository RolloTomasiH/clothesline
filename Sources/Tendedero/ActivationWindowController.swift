import AppKit
import SwiftUI

/// Window controller for the Invitation Code Activation Dialog.
@MainActor
final class ActivationWindowController: NSWindowController {
    static let shared = ActivationWindowController()

    var onActivationSuccess: (() -> Void)?

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 330, height: 360),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.center()

        self.init(window: window)

        let rootView = ActivationView(
            onActivated: { [weak self] in
                self?.close()
                self?.onActivationSuccess?()
            },
            onCancel: { [weak self] in
                if !ActivationManager.shared.isActivated {
                    NSApp.terminate(nil)
                } else {
                    self?.close()
                }
            }
        )

        window.contentView = NSHostingView(rootView: rootView)
    }

    func show(onSuccess: (() -> Void)? = nil) {
        if let onSuccess {
            self.onActivationSuccess = onSuccess
        }
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
