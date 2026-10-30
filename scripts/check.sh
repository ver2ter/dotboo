#!/bin/bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for script in "$project_root/build.sh" "$project_root"/scripts/*.sh; do
    bash -n "$script"
done
plutil -lint "$project_root/Resources/Info.plist"
"$project_root/scripts/build.sh"
app_name=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$project_root/Resources/Info.plist")
app="${BUILD_DIR:-$project_root/build}/$app_name.app"
codesign --verify --strict "$app"
if [ "${ARCHS:-}" = universal ]; then
    case "$(xcrun lipo -archs "$app/Contents/MacOS/$app_name")" in
        'arm64 x86_64'|'x86_64 arm64') ;;
        *) printf 'Expected both arm64 and x86_64 in the application.\n' >&2; exit 1 ;;
    esac
fi
test -s "$app/Contents/Resources/AppIcon.icns"
test -s "$app/Contents/Resources/LICENSE"
# This command reads status only; it does not launch the menu or register login.
"$app/Contents/MacOS/$app_name" --status | /usr/bin/python3 -c '
import json, sys
status = json.load(sys.stdin)
assert type(status.get("visible")) is bool, "Missing visibility status"
assert type(status.get("loginStatus")) is int, "Missing login status"
assert set(status) == {"visible", "loginStatus", "hasLastError", "version"}, "Unexpected diagnostic fields"
assert type(status["hasLastError"]) is bool, "Missing error flag"
assert isinstance(status["version"], str), "Missing version"
'
# Run menu/localization tests in an isolated bundle without changing preferences.
check_root=$(mktemp -d "${BUILD_DIR:-$project_root/build}/.localization-check.XXXXXX")
trap 'rm -rf -- "$check_root"' EXIT
check_app="$check_root/LocalizationCheck.app"
mkdir -p "$check_app/Contents/MacOS" "$check_app/Contents/Resources"
cp -R "$app/Contents/Resources/"*.lproj "$check_app/Contents/Resources/"
cat > "$check_app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>CFBundleExecutable</key><string>LocalizationCheck</string><key>CFBundleIdentifier</key><string>io.github.ver2ter.dotboo.localization-check</string><key>CFBundleDevelopmentRegion</key><string>en</string><key>LSUIElement</key><true/></dict></plist>
PLIST
xcrun swiftc -O -module-cache-path "${BUILD_DIR:-$project_root/build}/ModuleCache" -framework AppKit -framework ServiceManagement \
    "$project_root/Sources/Localization.swift" "$project_root/Sources/MenuBuilder.swift" \
    "$project_root/Sources/AppDelegate.swift" "$project_root/Sources/FinderVisibility.swift" \
    "$project_root/Tools/CheckLocalization.swift" -o "$check_app/Contents/MacOS/LocalizationCheck"
"$check_app/Contents/MacOS/LocalizationCheck"
printf 'Build, signature, resources, localizations, menus, and read-only status check passed.\n'
