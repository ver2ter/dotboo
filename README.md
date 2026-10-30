<div align="center">
  <img src="Resources/Branding/DotBoo.png" width="160" height="160" alt="DotBoo — outlined ghost with a wink">
  <h1>DotBoo</h1>
  <p><strong>A little ghost for your hidden files.</strong></p>
  <p>A tiny macOS menu bar app. Show what is hidden. Hide it again.</p>
  <p>
    <strong>macOS 13+</strong> · Apple silicon &amp; Intel · Native Swift · Free to use
  </p>
  <p>
    <a href="#get-dotboo">Get DotBoo</a> ·
    <a href="#how-it-works">How it works</a> ·
    <a href="#build-from-source">Build from source</a> ·
    <a href="CONTRIBUTING.md">Contribute</a>
  </p>
</div>

---

DotBoo lives in your menu bar and gives you a quick way to show or hide hidden
files and folders in Finder. One small control, always within reach.

No account, no analytics, and no network connection required. The application
is built with native macOS frameworks and has no third-party dependencies.

## What it does

- **Show and hide hidden files** across Finder.
- **Toggle with a right-click** on the menu bar icon.
- **See the current setting** through the eye icon and menu action.
- **Manage launch at login** from the same menu.
- **Stay out of the way** with no main window or Dock icon.

The interface is currently in French. Universal builds include both Apple
silicon and Intel executables, with macOS 13 Ventura as the deployment target.
See [verification coverage](docs/TESTING.md) for the checks to perform on each
supported system.

## Get DotBoo

**The first public release is being prepared.** You can currently
[build the application from source](#build-from-source). Packaged downloads will
be published in this repository's Releases section, together with a SHA-256
checksum.

To install a packaged version:

1. Extract the ZIP and move **DotBoo.app** to **Applications**.
2. Open DotBoo. Its eye icon appears in the menu bar.
3. Click the icon to open the menu, or right-click it to toggle visibility.

### First launch on macOS

DotBoo is currently **ad-hoc signed, without Apple Developer ID or notarization**.
macOS may block a downloaded copy on first launch. If you trust the official
source, follow [Apple's instructions](https://support.apple.com/en-us/102445):
attempt to open the application, then use **System Settings → Privacy & Security
→ Open Anyway**. Keep macOS security protections enabled.

On first launch, DotBoo also attempts to enable launch at login. You can turn
this off using **Ouvrir à la connexion** in its menu. If macOS requires approval,
the menu provides a link to Login Items in System Settings.

## How it works

| Action | Result |
| --- | --- |
| Left-click the eye icon | Open the menu and refresh the displayed setting |
| Choose **Afficher les fichiers cachés** | Show hidden files and folders |
| Choose **Masquer les fichiers cachés** | Hide them again |
| Right-click the eye icon | Switch between the two states |
| Choose **Quitter DotBoo** | Quit while keeping the current Finder setting |

**Finder restarts when you toggle visibility.** This can interrupt Finder
activity. The setting applies globally and remains in effect after DotBoo quits.

DotBoo changes visibility only. It does not change file contents, permissions,
or hidden attributes. Hiding a file does not encrypt it or restrict access.

To uninstall, turn off launch at login, quit DotBoo, and move it to the Trash.
If you want hidden files hidden afterwards, select that setting before quitting.

## Privacy

DotBoo does not scan your folders, send diagnostics, or collect usage data.
It reads and writes Finder's hidden-file preference and keeps its login-setup
flag and last error locally. Launch at login uses Apple's ServiceManagement
framework.

The optional `--status` diagnostic command is read-only and reports visibility,
login status, app version, and whether a local error exists. It does not print
local paths or error messages.

## Build from source

On a Mac, install Xcode or Apple's Command Line Tools (`xcode-select --install`).
From the project directory, run:

```sh
./build.sh
open build/DotBoo.app
```

To build for Apple silicon and Intel and run the read-only checks:

```sh
ARCHS=universal ./scripts/check.sh
```

To create and verify the universal ZIP and its checksum:

```sh
./scripts/package.sh
```

The output is written to `build/` and `dist/`, both excluded from Git. The build
uses Apple's tools directly; there is no package manager or Xcode project to
configure.

## Documentation and feedback

- [Contributing](CONTRIBUTING.md) — source organization and how to propose a change.
- [Verification](docs/TESTING.md) — automated checks and manual scenarios.
- [Release guide](docs/RELEASING.md) — preparing a downloadable version.
- [Changelog](CHANGELOG.md) — changes between versions.
- [Security policy](SECURITY.md) — reporting a suspected vulnerability.

For bugs or ideas, use this repository's Issues section once it is public.
Include the DotBoo version, macOS version, Mac architecture, and steps to
reproduce the problem. Contributions are welcome through pull requests under
the [contribution guidelines](CONTRIBUTING.md).

## License

DotBoo is **free for personal and professional end-user use** under the
[DotBoo Source-Available License](LICENSE).

You can inspect and compile the source, and propose changes through pull
requests. Resale, commercial exploitation of the code, and redistribution
outside the permitted channels require written permission. GitHub's public
viewing and forking rights still apply. This is source-available software,
not an OSI-approved open-source project.

Copyright © 2026 [ver2ter](https://github.com/ver2ter).
