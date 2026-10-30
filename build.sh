#!/bin/bash
# Compatibility entry point. The build implementation lives in scripts/.
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "$project_root/scripts/build.sh" "$@"
