#!/bin/bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export ARCHS=universal
"$project_root/scripts/check.sh"
plist="$project_root/Resources/Info.plist"
app_name=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$plist")
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")
dist_root="$project_root/dist"
mkdir -p "$dist_root"
archive="$app_name-$version-universal.zip"
work_dir=$(mktemp -d "$dist_root/.package.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT
ditto -c -k --keepParent --norsrc "${BUILD_DIR:-$project_root/build}/$app_name.app" "$work_dir/$archive"
# Verify the actual download, including integrity after ZIP extraction.
ditto -x -k "$work_dir/$archive" "$work_dir/extracted"
codesign --verify --strict "$work_dir/extracted/$app_name.app"
cmp "$project_root/LICENSE" "$work_dir/extracted/$app_name.app/Contents/Resources/LICENSE"
(cd "$work_dir" && shasum -a 256 "$archive" > "$archive.sha256" && shasum -a 256 -c "$archive.sha256")
mv "$work_dir/$archive" "$work_dir/$archive.sha256" "$dist_root/"
printf 'Packaged: %s\n' "$dist_root/$archive"
printf 'This archive is not notarized. See docs/RELEASING.md before publishing.\n'
