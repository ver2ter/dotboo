import AppKit

@MainActor
enum MenuBuilder {
    static func make(visible: Bool, loginState: NSControl.StateValue,
                     requiresApproval: Bool, updating: Bool = false,
                     target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false
        @discardableResult
        func add(_ title: String, action: String? = nil) -> NSMenuItem {
            let item = NSMenuItem(title: title,
                action: action.map(NSSelectorFromString), keyEquivalent: "")
            item.target = target
            item.isEnabled = action != nil
            menu.addItem(item)
            return item
        }
        add("DotBoo")
        add(L10n.text(visible ? "visibility.hide" : "visibility.show"),
            action: "toggleVisibility").isEnabled = !updating
        add(L10n.text("menu.rightClick"))
        add(L10n.text("menu.finderRestart"))
        menu.addItem(.separator())
        add(L10n.text("menu.login"), action: "toggleLogin").state = loginState
        if requiresApproval { add(L10n.text("menu.approval"), action: "openLoginSettings") }
        let languageItem = add(L10n.text("menu.language"))
        languageItem.isEnabled = true
        let languages = NSMenu()
        languages.autoenablesItems = false
        for code in [""] + L10n.languages {
            let item = NSMenuItem(title: code.isEmpty ? L10n.text("menu.systemLanguage") : L10n.languageName(code),
                                  action: NSSelectorFromString("selectLanguage:"), keyEquivalent: "")
            item.target = target
            item.representedObject = code
            item.state = code == L10n.selection ? .on : .off
            languages.addItem(item)
        }
        languageItem.submenu = languages
        menu.addItem(.separator())
        add(L10n.text("menu.quit"), action: "quit")
        return menu
    }
}
