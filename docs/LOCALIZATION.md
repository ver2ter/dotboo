# Translations

DotBoo uses native `.lproj/Localizable.strings` resources. English is the base
language; French is included. It follows the system's preferred languages unless
the user chooses a language in the menu. That choice stays on the Mac and takes
effect immediately, including the menu, tooltip, accessibility text, and app-authored
errors. Errors provided by macOS itself may follow the system language.

## Add a language

1. Copy `Resources/en.lproj` to a language folder, for example
   `Resources/de.lproj` for German or `Resources/pt-BR.lproj` for Brazilian Portuguese.
2. Translate the values in `Localizable.strings`. Keep every key unchanged,
   preserve `DotBoo`, and escape embedded quotes as `\"`.
3. Run `ARCHS=universal ./scripts/check.sh`. All language tables must contain
   the same keys and nonempty values. Check the actual menu for natural wording
   and excessive length.
4. Submit the translation through a pull request.

No Swift file, build list, or language-picker list needs editing. The build copies
every `.lproj` directory, the menu discovers them from the application bundle,
and the checks exercise each one. Names are displayed in the language itself.
If a translation key is missing at runtime, its English value is used; incomplete
tables fail the checks before release.

## Update the README images

On a Mac with an active graphical session, run:

```sh
./scripts/screenshots.sh
```

This opens a temporary neutral preview window for each language and captures
only its native menu window. The developer helper uses the production menu
builder with fixed sample settings. It does not launch DotBoo, alter Finder,
register login items, or capture the desktop. It is never included in the app.
Screen-recording permission may be needed for the terminal running this tool.
If capturing fails, it stops rather than falling back to a full-screen capture.
Review `docs/assets/menu-*.png` before committing. To feature a new language in
the README, add its image explicitly; generation does not edit the README.
