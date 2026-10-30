# Changelog

## 1.1.0-beta.1 — 2026-10-30

- Add English and French, automatic system-language matching, and an immediate
  language selector in the menu.
- Discover translations from native `.lproj` resource folders, with no language
  list to maintain in code; document the translation contribution process.
- Add isolated native menu captures to the README without desktop information.
- Register launch at login when a fresh installation has no existing service record.
- Check translation completeness and both visibility states in every language.

## 1.0.3 — Initial public source snapshot — 2026-10-30

- Adopt the approved outlined ghost logo and ivory macOS application icon.
- Use the public bundle identity `io.github.ver2ter.dotboo`.
- Keep local paths and error messages out of diagnostic output.
- The new bundle identity starts with separate local preferences and login-item
  registration from private development builds.

## 1.0.2 — Private development build

- Name the application DotBoo and use `dotboo` for the repository and directory.
- Organize application sources, resources, and build tools separately.
- Provide universal Apple silicon/Intel builds and verified ZIP downloads.
- Add build and packaging checks for pull requests, contribution guidance, and
  installation and release documentation.
- Permit personal and professional end-user use under the DotBoo source-available
  license, while restricting resale and commercial exploitation of the code.

Builds are ad-hoc signed, not notarized.
