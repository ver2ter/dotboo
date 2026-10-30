#!/bin/bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_root="${BUILD_DIR:-$project_root/build}"
plist="$project_root/Resources/Info.plist"
app_name=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$plist")
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")
minimum_macos=$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$plist")
architecture="${ARCHS:-$(uname -m)}"

case "$architecture" in
    arm64|x86_64) architectures=("$architecture") ;;
    universal) architectures=(arm64 x86_64) ;;
    *) printf 'ARCHS must be arm64, x86_64, or universal.\n' >&2; exit 64 ;;
esac

mkdir -p "$build_root"
build_root="$(cd -- "$build_root" && pwd)"
work_dir=$(mktemp -d "$build_root/.build.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT
app="$work_dir/$app_name.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources" "$build_root/ModuleCache"
cp "$plist" "$app/Contents/Info.plist"
for localization in "$project_root"/Resources/*.lproj; do
    cp -R "$localization" "$app/Contents/Resources/"
done

executables=()
for arch in "${architectures[@]}"; do
    executable="$work_dir/$app_name-$arch"
    xcrun swiftc -O -whole-module-optimization \
        -target "$arch-apple-macos$minimum_macos" \
        -module-cache-path "$build_root/ModuleCache" \
        -framework AppKit -framework ServiceManagement \
        "$project_root"/Sources/*.swift -o "$executable"
    executables+=("$executable")
done
if [ "${#executables[@]}" -eq 1 ]; then
    cp "${executables[0]}" "$app/Contents/MacOS/$app_name"
else
    xcrun lipo -create "${executables[@]}" -output "$app/Contents/MacOS/$app_name"
fi

# Run the icon generator for this Mac, even when cross-compiling the app.
xcrun swiftc -O -target "$(uname -m)-apple-macos$minimum_macos" \
    -module-cache-path "$build_root/ModuleCache" -framework AppKit \
    "$project_root/Tools/GenerateIcons.swift" -o "$work_dir/generate-icons"
"$work_dir/generate-icons" "$project_root/Resources/Branding/DotBoo.png" "$work_dir/AppIcon.iconset"
iconutil -c icns "$work_dir/AppIcon.iconset" -o "$app/Contents/Resources/AppIcon.icns"
cp "$project_root/LICENSE" "$app/Contents/Resources/LICENSE"

identity="${CODESIGN_IDENTITY:--}"
if [ "$identity" != '-' ]; then
    codesign --force --sign "$identity" --identifier "$bundle_id" --options runtime --timestamp "$app"
else
    codesign --force --sign - --identifier "$bundle_id" "$app"
fi
codesign --verify --strict "$app"

# Replace only the generated app bundle, after a successful build.
rm -rf -- "$build_root/$app_name.app"
mv "$app" "$build_root/$app_name.app"
printf 'Built: %s\n' "$build_root/$app_name.app"
