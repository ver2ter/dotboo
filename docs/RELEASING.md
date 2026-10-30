# Releasing

## Prepare the public repository

1. Use **DotBoo** for the application and **dotboo** for the repository and local
   directory. The GitHub repository is `ver2ter/dotboo`. These lowercase
   repository names are a project convention, not a GitHub requirement.
   `Resources/Info.plist` owns the application's name and version. The public
   bundle identifier is `io.github.ver2ter.dotboo`. Keep this identifier stable
   for future public updates.
2. Review `LICENSE` and the README license summary. This is a custom
   source-available license with restrictions on commercial exploitation, not MIT or an OSI-approved license.
   Do not add an open-source badge. GitHub's public-repository forking rights
   still apply.
3. Review the files to be published with `git status --short` and
   `git ls-files`. Ensure generated archives, caches, credentials, and private
   context are excluded. Do not use a force-add to publish ignored files.
4. Create a public repository under the intended GitHub account. Enable Issues,
   private vulnerability reporting if available, and secret scanning/push
   protection. Protect `main` against force pushes when the account supports it.
5. Push the reviewed source and wait for the build workflow. Keep release assets
   in GitHub Releases rather than in the source tree.

## Build and verify

1. Set `DotBooReleaseVersion` in `Resources/Info.plist` to the full release
   version (for example `1.1.0-beta.1`). Keep `CFBundleShortVersionString` numeric
   (`1.1.0`) for macOS, and increment `CFBundleVersion` for every new build.
   The archive name and CLI status use the full release version.
2. Run `./scripts/package.sh`. It builds a universal application, runs checks,
   embeds the license, and writes the ZIP and checksum to `dist/`.
3. Complete and record the relevant [manual checks](TESTING.md). Separate tested
   behavior from unavailable macOS or hardware coverage.
4. Check archive contents with `unzip -l dist/*.zip`. Verify extraction preserves
   the app signature. Only the application bundle belongs in the release ZIP.
5. Commit the reviewed source, tag that commit as `vX.Y.Z`, and publish a GitHub
   Release from the same tag with the ZIP and its `.sha256` file. Mark alpha,
   beta, and release-candidate versions as pre-releases. Attach and verify all
   assets in the draft before publishing: immutable releases lock their assets
   and tag on publication.

## Current distribution: no Developer ID

The default build is ad-hoc signed. This is not an Apple Developer ID signature
and does not provide notarization. State this in the release notes. Link to
[Apple's instructions](https://support.apple.com/en-us/102445) for the first
launch through System Settings → Privacy & Security → Open Anyway. Do not tell
users to disable Gatekeeper or remove quarantine attributes globally.

Include in release notes: version, macOS 13+ requirement, Apple silicon/Intel
universal binary, English/French interfaces, first-launch login registration, Finder
restart when toggling, source-available license, and actual verification coverage.
Do not claim a signed-and-notarized release.

## Future Developer ID distribution

After obtaining an Apple Developer Program membership and a Developer ID
Application certificate, set `CODESIGN_IDENTITY` to that identity when building.
The build then enables the hardened runtime and secure timestamp. Never commit
private signing keys, certificates with private keys, or notarization passwords.

Notarize the ZIP with `xcrun notarytool submit` using credentials stored in
Keychain. After acceptance, staple and validate the ticket on the app, then
recreate the ZIP and checksum from the stapled app. Do not rerun the build after
stapling, because that would replace the app and discard its ticket. Verify the
final archive on a clean account before publication. Follow
[Apple's current notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).
