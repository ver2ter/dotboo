import AppKit
import CoreGraphics

@MainActor
final class CaptureDelegate: NSObject, NSApplicationDelegate {
    var backdrop: NSWindow!
    var menu: NSMenu!
    let language: String
    let output: String
    init(language: String, output: String) {
        self.language = language
        self.output = output
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        L10n.previewLanguage = language
        // A dedicated neutral window prevents any personal background from
        // being sampled by the native menu's translucent material.
        backdrop = NSWindow(contentRect: NSRect(x: 200, y: 200, width: 900, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        backdrop.backgroundColor = NSColor(calibratedWhite: 0.94, alpha: 1)
        backdrop.isOpaque = true
        backdrop.level = NSWindow.Level(rawValue: NSWindow.Level.popUpMenu.rawValue - 1)
        backdrop.appearance = NSAppearance(named: .aqua)
        menu = MenuBuilder.make(visible: false, loginState: .off, requiresApproval: false, target: self)
        backdrop.setContentSize(NSSize(width: menu.size.width + 64, height: menu.size.height + 64))
        backdrop.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.showMenu() }
    }
    func showMenu() {
        let timer = Timer(timeInterval: 2, repeats: false) { _ in
            MainActor.assumeIsolated {
                // Inspect only this helper's own windows. Never capture the screen.
                let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
                let own = windows.filter { ($0[kCGWindowOwnerPID as String] as? Int) == Int(getpid()) }
                let candidates = own.filter {
                    ($0[kCGWindowNumber as String] as? Int) != self.backdrop.windowNumber &&
                    ($0[kCGWindowLayer as String] as? Int ?? 0) >= NSWindow.Level.popUpMenu.rawValue
                }
                guard let capture = candidates.first,
                      let id = capture[kCGWindowNumber as String] as? Int else {
                    fputs("Could not find the helper's native menu window.\n", stderr)
                    self.menu.cancelTracking()
                    exit(1)
                }
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
                process.arguments = ["-x", "-o", "-l", String(id), self.output]
                do {
                    try process.run()
                    process.waitUntilExit()
                    self.menu.cancelTracking()
                    exit(process.terminationStatus)
                } catch {
                    fputs("Menu-only capture failed.\n", stderr)
                    exit(1)
                }
            }
        }
        RunLoop.main.add(timer, forMode: .eventTracking)
        RunLoop.main.add(timer, forMode: .default)
        menu.popUp(positioning: nil, at: NSPoint(x: 32, y: menu.size.height + 32), in: backdrop.contentView)
        // Cancellation before the timer fires must not count as a capture.
        exit(1)
    }
    @objc func toggleVisibility() {}
    @objc func toggleLogin() {}
    @objc func openLoginSettings() {}
    @objc func selectLanguage(_ sender: NSMenuItem) {}
    @objc func quit() {}
}

@main
struct CaptureMenu {
    @MainActor static func main() {
        guard CommandLine.arguments.count == 3 else { exit(64) }
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let delegate = CaptureDelegate(language: CommandLine.arguments[1], output: CommandLine.arguments[2])
        app.delegate = delegate
        app.run()
    }
}
