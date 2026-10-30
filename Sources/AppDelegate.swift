import AppKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "DotBoo"
    private var statusItem: NSStatusItem!
    private let menu = NSMenu()
    private var visibilityItem: NSMenuItem!
    private var loginItem: NSMenuItem!
    private var approvalItem: NSMenuItem!
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
        menu.delegate = self
        menu.autoenablesItems = false
        let title = NSMenuItem(title: appName, action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)
        visibilityItem = addItem("", action: #selector(toggleVisibility))
        let hint = NSMenuItem(title: "Clic droit sur l’icône : basculer", action: nil, keyEquivalent: "")
        hint.isEnabled = false
        menu.addItem(hint)
        let refreshHint = NSMenuItem(title: "Le Finder se relance pour appliquer le réglage.", action: nil, keyEquivalent: "")
        refreshHint.isEnabled = false
        menu.addItem(refreshHint)
        menu.addItem(.separator())
        loginItem = addItem("Ouvrir à la connexion", action: #selector(toggleLogin))
        approvalItem = addItem("Autoriser dans les Réglages Système…", action: #selector(openLoginSettings))
        menu.addItem(.separator())
        addItem("Quitter \(appName)", action: #selector(quit))
        refresh()
        configureInitialLogin()
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    @discardableResult
    private func addItem(_ title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        menu.addItem(item)
        return item
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

    func menuWillOpen(_ menu: NSMenu) { refresh() }

    @objc private func refresh() {
        let visible = FinderVisibility.isVisible
        let image = NSImage(systemSymbolName: visible ? "eye" : "eye.slash",
                            accessibilityDescription: visible ? "Fichiers cachés visibles" : "Fichiers cachés masqués")
        image?.isTemplate = true
        statusItem.button?.image = image
        statusItem.button?.toolTip = "Fichiers cachés \(visible ? "visibles" : "masqués") · Clic droit pour basculer"
        visibilityItem.title = visible ? "Masquer les fichiers cachés" : "Afficher les fichiers cachés"
        visibilityItem.isEnabled = !isUpdating
        let status = SMAppService.mainApp.status
        loginItem.state = status == .enabled ? .on : (status == .requiresApproval ? .mixed : .off)
        approvalItem.isHidden = status != .requiresApproval
    }

    @objc private func toggleVisibility() {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false; refresh() }
        do {
            try FinderVisibility.setVisible(!FinderVisibility.isVisible)
            UserDefaults.standard.removeObject(forKey: "lastOperationError")
        } catch { showError(error, title: "Impossible d’actualiser le Finder") }
    }

    private func configureInitialLogin() {
        guard !UserDefaults.standard.bool(forKey: setupKey) else { return }
        do {
            let status = SMAppService.mainApp.status
            if status == .notRegistered { try SMAppService.mainApp.register() }
            if SMAppService.mainApp.status == .enabled || SMAppService.mainApp.status == .requiresApproval {
                UserDefaults.standard.set(true, forKey: setupKey)
            }
        } catch { showError(error, title: "Le démarrage automatique nécessite ton attention") }
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
        } catch { showError(error, title: "Impossible de modifier le démarrage automatique") }
        refresh()
    }

    @objc private func openLoginSettings() { SMAppService.openSystemSettingsLoginItems() }
    @objc private func quit() { NSApp.terminate(nil) }

    private func showError(_ error: Error, title: String) {
        UserDefaults.standard.set(error.localizedDescription, forKey: "lastOperationError")
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
