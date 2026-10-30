#!/bin/bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$project_root/build" "$project_root/docs/assets"
work_dir=$(mktemp -d "$project_root/build/.screenshots.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT
app="$work_dir/MenuPreview.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp -R "$project_root"/Resources/*.lproj "$app/Contents/Resources/"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>CFBundleExecutable</key><string>MenuPreview</string><key>CFBundleIdentifier</key><string>io.github.ver2ter.dotboo.preview</string><key>CFBundleDevelopmentRegion</key><string>en</string><key>LSUIElement</key><true/></dict></plist>
PLIST
xcrun swiftc -O -module-cache-path "$project_root/build/ModuleCache" -framework AppKit \
    "$project_root/Sources/Localization.swift" "$project_root/Sources/MenuBuilder.swift" \
    "$project_root/Tools/CaptureMenu.swift" -o "$app/Contents/MacOS/MenuPreview"
for localization in "$project_root"/Resources/*.lproj; do
    language=$(basename "$localization" .lproj)
    "$app/Contents/MacOS/MenuPreview" "$language" "$work_dir/menu-$language.png"
    test -s "$work_dir/menu-$language.png"
    mv "$work_dir/menu-$language.png" "$project_root/docs/assets/"
done
printf 'Native menu captures saved in docs/assets/. No desktop capture is used.\n'
