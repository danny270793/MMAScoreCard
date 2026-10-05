#!/usr/bin/env bash
# Usage: scripts/start.sh [extra flutter run args, e.g. -d <device-id>]
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_FILE=".env.json"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Create it from .env.example.json:" >&2
  echo "  cp .env.example.json $ENV_FILE" >&2
  exit 1
fi

flutter pub get
flutter run --dart-define-from-file="$ENV_FILE" "$@"
