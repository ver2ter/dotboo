# Publication review — 30 October 2026

## Assessment

The repository layout is proportionate to a small native macOS application.
Application code, resources, build tools, and generated output have separate
locations. No package manager, Xcode project, or third-party runtime dependency
is necessary for this build approach.

GitHub recommends community files; it does not require a particular directory
layout or a complete community-profile score to publish a repository. README,
LICENSE, CONTRIBUTING, SECURITY, and issue/PR templates are present. Community
expectations are included in CONTRIBUTING. A separate code of conduct and
CODEOWNERS are optional future additions for a larger contributor community.

## Changes made during review

- Use **DotBoo** for the app and **dotboo** for the repository and directory.
  This is a deliberate naming convention, not a GitHub capitalization rule.
- Set the new local build to **1.0.2 (3)** and record it as unreleased.
- The initial review retained the local bundle identity. The subsequent privacy
  review replaces it with `io.github.ver2ter.dotboo` before public distribution.
- Clarify the custom license: personal and professional end-user use is free;
  resale, commercial code exploitation, and unauthorized redistribution remain
  restricted. Source modifications are permitted for upstream contributions.
  This license is not a standard open-source license or a legal certification.
- Verify the actual ZIP by extracting it, checking the app signature and embedded
  license, and checking its SHA-256 checksum before replacing release artifacts.
- Run the packaging verification in CI, rather than stopping at compilation.
- Keep CI contents permission read-only, checkout pinned to a commit, and checkout
  credentials unpersisted. Add monthly Dependabot checks for GitHub Actions.

## Evidence and limits

On macOS 27.0.1, from the renamed directory, the universal build, read-only JSON
status check, signature check after ZIP extraction, embedded license comparison,
and checksum verification passed. Both arm64 and x86_64 slices are present.

A pattern scan of publication candidates and the existing Git history found no
private-key/token patterns or absolute personal home paths. This is a bounded
check, not a guarantee that every possible secret format is detected.

No Finder toggle, login registration, real Intel execution, macOS 13 execution,
or clean-account downloaded-app Gatekeeper test was performed in this review.
The build is ad-hoc signed and not notarized. CI is configured locally; no GitHub
run or public release is claimed.

## Remaining publication work

Create/configure the public repository, enable private vulnerability reporting,
push the reviewed commits, and observe the first CI run. Before offering the
binary as a tested release, record the available manual checks in TESTING.md,
including first launch and the Finder toggle. Publish the ZIP and checksum from
the corresponding source tag. Keep the lack of Developer ID/notarization visible
in installation instructions and release notes.

## Primary references

- [GitHub community profile recommendations](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/about-community-profiles-for-public-repositories)
- [GitHub repository licensing and public forks](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- [GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use)
- [Apple: opening downloaded apps safely](https://support.apple.com/en-us/102445)
