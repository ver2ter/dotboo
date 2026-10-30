import AppKit

enum FinderVisibility {
    static let domain = "com.apple.finder" as CFString
    static let key = "AppleShowAllFiles" as CFString

    static var isVisible: Bool {
        CFPreferencesAppSynchronize(domain)
        return (CFPreferencesCopyAppValue(key, domain) as? NSNumber)?.boolValue ?? false
    }

    static func setVisible(_ value: Bool) throws {
        CFPreferencesSetAppValue(key, value ? kCFBooleanTrue : kCFBooleanFalse, domain)
        guard CFPreferencesAppSynchronize(domain), isVisible == value else {
            throw NSError(domain: "FichiersMasques", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: L10n.text("error.finder.save")])
        }
        // Finder automatically relaunches after termination. Arguments are never shell code.
        let restart = Process()
        restart.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        restart.arguments = ["Finder"]
        restart.standardOutput = FileHandle.nullDevice
        restart.standardError = FileHandle.nullDevice
        try restart.run()
        restart.waitUntilExit()
        // Exit 1 simply means Finder was not running; its next launch reads the preference.
        guard restart.terminationStatus == 0 || restart.terminationStatus == 1 else {
            throw NSError(domain: "FichiersMasques", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: L10n.text("error.finder.refresh")])
        }
    }
}
