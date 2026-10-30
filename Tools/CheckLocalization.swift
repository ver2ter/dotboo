import AppKit

@main
struct CheckLocalization {
    @MainActor static func main() throws {
        _ = NSApplication.shared
        let target = AppDelegate()
        let resources = Bundle.main.resourceURL!
        func table(_ language: String) throws -> [String: String] {
            let data = try Data(contentsOf: resources.appendingPathComponent("\(language).lproj/Localizable.strings"))
            return try PropertyListSerialization.propertyList(from: data, format: nil) as! [String: String]
        }
        let english = try table("en")
        precondition(L10n.preferredLanguage(for: ["fr-CA"]) == "fr")
        precondition(L10n.preferredLanguage(for: ["zz-ZZ"]) == "en")
        precondition(Set(L10n.languages).isSuperset(of: ["en", "fr"]))
        for language in L10n.languages {
            let strings = try table(language)
            precondition(Set(strings.keys) == Set(english.keys), "Translation keys differ: \(language)")
            precondition(strings.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
            L10n.previewLanguage = language
            precondition(L10n.language == language)
            for key in strings.keys { precondition(L10n.text(key) == strings[key]) }
            for visible in [false, true] {
                let menu = MenuBuilder.make(visible: visible, loginState: .off,
                    requiresApproval: false, target: target)
                for item in menu.items + menu.items.flatMap({ $0.submenu?.items ?? [] }) {
                    if item.submenu == nil, let action = item.action {
                        precondition(target.responds(to: action), "Missing menu action: \(NSStringFromSelector(action))")
                    }
                }
                precondition(menu.items[1].title == strings[visible ? "visibility.hide" : "visibility.show"])
                precondition(!menu.items.contains { $0.title == strings["menu.approval"] })
                let submenu = menu.items.first { $0.title == strings["menu.language"] }!.submenu!
                precondition(submenu.items.count == L10n.languages.count + 1)
                precondition(submenu.items.dropFirst().allSatisfy { $0.representedObject is String })
            }
            let menu = MenuBuilder.make(visible: true, loginState: .mixed,
                requiresApproval: true, updating: true, target: nil)
            precondition(!menu.items[1].isEnabled)
            precondition(menu.items.contains { $0.title == strings["menu.approval"] })
            precondition(menu.items.first { $0.title == strings["menu.login"] }!.state == .mixed)
            precondition(L10n.text("missing.translation") == "missing.translation")
        }
        print("All translation tables and native menu states passed (\(L10n.languages.joined(separator: ", "))).")
    }
}
