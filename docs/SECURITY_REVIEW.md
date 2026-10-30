# Pre-publication security and privacy review

Reviewed locally on 30 October 2026 for DotBoo 1.0.3 (4), before the first push.

## Scope and corrections

- Reviewed all application sources, build/package scripts, GitHub workflow,
  publication files, PNG metadata, and generated application contents.
- Replaced the private development bundle identity with the public identifier
  `io.github.ver2ter.dotboo`. Existing private builds have separate preferences
  and login registration; no migration of the previous identity is shipped.
- Removed local bundle paths and raw error messages from `--status`. Its output
  is limited to visibility, login status, version, and an error-present flag.
- Prepared a clean initial public commit so that earlier private identifiers do
  not remain in published history. The previous local history is backed up under
  `.private/`, which is excluded from Git and must never be uploaded.
- Use the maintainer's public GitHub handle and GitHub no-reply commit address.

## Code observations

The app has no networking, telemetry, upload, file scanning, or account features.
Its persistent state is local: Finder visibility, login setup, and the last local
operation error. Error details can appear in a local alert but are not sent out
or included in CLI status output.

Finder restart uses the fixed executable `/usr/bin/killall` with a fixed `Finder`
argument. No user input is evaluated as shell code. The app does not request
administrator privileges or modify file contents or permissions.

Launch-at-login registration on first launch is existing behavior documented in
the README. The user can disable it. This review does not change that behavior.

The CI workflow has read-only repository permission, pins checkout to a commit,
does not persist checkout credentials, and uses no repository secrets. It does
not execute pull-request code in a privileged `pull_request_target` workflow.

## Artifact and privacy checks

The universal build and restricted status-schema check passed on macOS 27.0.1.
The packaged app's signature and embedded license passed verification after ZIP
extraction, and the ZIP checksum passed verification. The application icon was
visually inspected after rendering from the approved artwork.

The reviewed publication files and compiled app contain no detected private
maintainer name, personal email, absolute home-directory path, or known credential
pattern. The PNG retains generated-content provenance; the email addresses in
that metadata belong to its certificate authority, not the maintainer. The
public handle `ver2ter` is intentionally visible in project attribution.

## Limits

This is a manual source review with targeted pattern and artifact checks, not
an independent penetration test or a guarantee that every possible issue is
absent. Real Intel/macOS 13 execution, UI actions, login behavior, and first-launch
Gatekeeper behavior on a clean account still need the manual checks in TESTING.md.
The application is ad-hoc signed and is not notarized by Apple.
