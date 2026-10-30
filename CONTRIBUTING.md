# Contributing

Keep changes focused on a small, native menu bar utility. Open an issue before
proposing a large feature or changing how Finder is restarted.

## License

Read [LICENSE](LICENSE) before working on a change. This is a source-available project with free personal and professional end-user
use; commercial exploitation of the code is restricted. Modification is permitted for preparing an upstream
contribution; submitting a pull request licenses your contribution under the
same terms. Only submit work you have the right to contribute. GitHub forks
needed for pull requests are permitted under the applicable GitHub terms.

## Development

Use a Mac with Xcode or Apple's Command Line Tools installed. Run:

```sh
ARCHS=universal ./scripts/check.sh
```

The check compiles both architectures, checks the bundle signature and resources,
and runs a read-only diagnostic command. It does not toggle Finder visibility or
register launch at login.

For menu or preference changes, complete the relevant scenarios in
[docs/TESTING.md](docs/TESTING.md) and describe your results in the pull request.
State your macOS version and architecture; cross-compiling Intel code on Apple
silicon does not verify behavior on an Intel Mac.

## Source organization

- `Sources/main.swift`: application startup and diagnostic commands.
- `Sources/AppDelegate.swift`: menu bar UI and login-item actions.
- `Sources/FinderVisibility.swift`: Finder preference and refresh operation.
- `Resources/Info.plist`: bundle identity and version.
- `Tools/GenerateIcons.swift`: build-time icon rendering.

Keep generated bundles, archives, credentials, personal logs, and editor state
out of commits. Avoid adding dependencies for work covered by system frameworks.
Do not include unrelated formatting or generated output in pull requests.

## Community expectations

Be respectful, discuss the change rather than the person, and do not post
harassment or private information. The maintainer may moderate discussions and
close contributions that do not fit the project. This is a personal project;
there is no guaranteed response time or support service.
