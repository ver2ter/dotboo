# Verification

## Automated checks

```sh
ARCHS=universal ./scripts/check.sh
```

This validates shell syntax, the property list, compilation for Apple silicon
and Intel, the final bundle signature, icon and license resources, and JSON
output from `--status`. An isolated helper also checks bundled translation keys,
nonempty values, language discovery, and native menu visibility, login-approval,
and disabled states in each language. It reads preferences but does not change them, restart
Finder, launch the UI, or modify login items.

`./scripts/package.sh` additionally verifies the extracted archive signature
and its SHA-256 checksum. GitHub Actions runs the complete packaging check on
macOS 15 for pushes to `main` and pull requests. A successful build for macOS 13 does not establish runtime coverage
of all supported macOS versions.

## Manual release checks

Use the exact packaged app, preferably in a separate macOS test account. Move it
to Applications before testing login behavior. Record the macOS version and Mac
architecture, and restore the original Finder and login settings afterwards.

- Launch: one eye icon appears in the menu bar; no Dock icon or window appears.
- Left-click: the menu opens with the correct current visibility action.
- Toggle from the menu: hidden files appear or disappear after Finder restarts.
- Right-click: the state toggles once and the icon updates.
- Languages: select English, Français, then System default; verify immediate
  menu/tooltip changes, correct labels in both visibility states, and persistence
  after quitting and reopening. A new translation must appear automatically.
- External preference change: opening the menu refreshes its state.
- Appearance and accessibility: check light/dark menu bars and VoiceOver labels.
- Launch at login: check first-launch registration, disable, re-enable, and
  the approval-needed state in System Settings. Verify after logging in again.
- Error handling: if a Finder preference or login operation fails, an actionable
  error is shown and the visibility action becomes usable again.
- Quit: the icon disappears; the chosen Finder visibility setting persists.
- Distribution: download the release ZIP in a browser to a clean account, verify
  its checksum, extract it, and follow the documented Gatekeeper steps.
- Compatibility: test on a real Intel Mac and the oldest macOS version supported
  when available; record any unavailable environments in release notes.

Do not treat the read-only status check as validation of menu interaction,
Finder restarts, login registration, or first-launch Gatekeeper behavior.
