import AppKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "DotBoo"
    private var statusItem: NSStatusItem!
    private var menu = NSMenu()
    private var isUpdating = false
    private let setupKey = "didConfigureLoginItem"

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.setAccessibilityLabel(appName)
        }
        refresh()
        configureInitialLogin()
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            toggleVisibility()
        } else {
            refresh()
            statusItem.menu = menu
            sender.performClick(nil)
            statusItem.menu = nil
        }
    }

    @objc private func refresh() {
        let visible = FinderVisibility.isVisible
        let image = NSImage(systemSymbolName: visible ? "eye" : "eye.slash",
                            accessibilityDescription: L10n.text(visible ? "visibility.visible" : "visibility.hidden"))
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.toolTip = L10n.text(visible ? "visibility.tooltip.visible" : "visibility.tooltip.hidden")
        let status = SMAppService.mainApp.status
        menu = MenuBuilder.make(visible: visible,
            loginState: status == .enabled ? .on : (status == .requiresApproval ? .mixed : .off),
            requiresApproval: status == .requiresApproval, updating: isUpdating, target: self)
    }

    @objc private func selectLanguage(_ sender: NSMenuItem) {
        guard let code = sender.representedObject as? String,
              code.isEmpty || L10n.languages.contains(code) else { return }
        if code.isEmpty { UserDefaults.standard.removeObject(forKey: L10n.preferenceKey) }
        else { UserDefaults.standard.set(code, forKey: L10n.preferenceKey) }
        refresh()
    }

    @objc private func toggleVisibility() {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false; refresh() }
        do {
            try FinderVisibility.setVisible(!FinderVisibility.isVisible)
            UserDefaults.standard.removeObject(forKey: "lastOperationError")
        } catch { showError(error, title: L10n.text("error.finder.title")) }
    }

    private func configureInitialLogin() {
        guard !UserDefaults.standard.bool(forKey: setupKey) else { return }
        do {
            let status = SMAppService.mainApp.status
            // A fresh installation may have no Background Task Management record yet.
            if status == .notRegistered || status == .notFound { try SMAppService.mainApp.register() }
            if SMAppService.mainApp.status == .enabled || SMAppService.mainApp.status == .requiresApproval {
                UserDefaults.standard.set(true, forKey: setupKey)
            }
        } catch { showError(error, title: L10n.text("error.login.initial")) }
        refresh()
    }

    @objc private func toggleLogin() {
        do {
            switch SMAppService.mainApp.status {
            case .enabled: try SMAppService.mainApp.unregister()
            case .requiresApproval: SMAppService.openSystemSettingsLoginItems()
            default: try SMAppService.mainApp.register()
            }
            UserDefaults.standard.set(true, forKey: setupKey)
        } catch { showError(error, title: L10n.text("error.login.change")) }
        refresh()
    }

    @objc private func openLoginSettings() { SMAppService.openSystemSettingsLoginItems() }
    @objc private func quit() { NSApp.terminate(nil) }

    private func showError(_ error: Error, title: String) {
        UserDefaults.standard.set(error.localizedDescription, forKey: "lastOperationError")
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: L10n.text("button.ok"))
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
