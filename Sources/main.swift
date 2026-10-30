import AppKit
import ServiceManagement

try MainActor.assumeIsolated {
    if CommandLine.arguments.contains("--unregister-login") {
        try SMAppService.mainApp.unregister()
    } else if CommandLine.arguments.contains("--register-login") {
        try SMAppService.mainApp.register()
    } else if CommandLine.arguments.contains("--status") {
        let data: [String: Any] = ["visible": FinderVisibility.isVisible,
            "loginStatus": SMAppService.mainApp.status.rawValue,
            "hasLastError": UserDefaults.standard.string(forKey: "lastOperationError")?.isEmpty == false,
            "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"]
        print(String(data: try JSONSerialization.data(withJSONObject: data, options: [.sortedKeys]), encoding: .utf8)!)
    } else {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        application.run()
    }
}
