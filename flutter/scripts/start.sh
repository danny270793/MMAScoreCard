#!/usr/bin/env bash
# Usage: scripts/start.sh [extra flutter run args, e.g. -d <device-id>]
set -euo pipefail
cd "$(dirname "$0")/.."

flutter pub get
flutter run "$@"
