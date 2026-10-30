import Foundation

enum L10n {
    static let preferenceKey = "interfaceLanguage"
    // Used only by the standalone documentation renderer; never persisted.
    static var previewLanguage: String?

    static var languages: [String] {
        Bundle.main.localizations.filter { $0 != "Base" }.sorted()
    }

    static var selection: String {
        UserDefaults.standard.string(forKey: preferenceKey) ?? ""
    }

    static var language: String {
        if let previewLanguage, languages.contains(previewLanguage) { return previewLanguage }
        if languages.contains(selection) { return selection }
        return preferredLanguage(for: Locale.preferredLanguages)
    }

    static func preferredLanguage(for preferences: [String]) -> String {
        Bundle.preferredLocalizations(from: languages,
            forPreferences: preferences + ["en"]).first ?? "en"
    }

    static func text(_ key: String) -> String {
        let fallback = localizedBundle("en")?.localizedString(forKey: key, value: key, table: nil) ?? key
        return localizedBundle(language)?.localizedString(forKey: key, value: fallback, table: nil) ?? fallback
    }

    static func languageName(_ code: String) -> String {
        let locale = Locale(identifier: code)
        return (locale.localizedString(forLanguageCode: code) ?? code).capitalized(with: locale)
    }

    private static func localizedBundle(_ code: String) -> Bundle? {
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }
}
