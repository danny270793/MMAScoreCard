#!/usr/bin/env bash
# Usage: scripts/build.sh [--platform android|ios] [--mode debug|release] [extra flutter build args]
set -euo pipefail
cd "$(dirname "$0")/.."

PLATFORM="android"
MODE="release"
EXTRA_ARGS=()

usage() {
  echo "Usage: $0 [--platform android|ios] [--mode debug|release] [extra flutter build args]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="${2:-}"; shift 2 ;;
    --platform=*) PLATFORM="${1#*=}"; shift ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --mode=*) MODE="${1#*=}"; shift ;;
    -h|--help) usage ;;
    *) EXTRA_ARGS+=("$1"); shift ;;
  esac
done

[[ "$PLATFORM" == "android" || "$PLATFORM" == "ios" ]] || { echo "Invalid --platform: $PLATFORM" >&2; usage; }
[[ "$MODE" == "debug" || "$MODE" == "release" ]] || { echo "Invalid --mode: $MODE" >&2; usage; }

ENV_FILE=".env.json"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Create it from .env.example.json:" >&2
  echo "  cp .env.example.json $ENV_FILE" >&2
  exit 1
fi

DEFINES=(--dart-define-from-file="$ENV_FILE")

flutter pub get

case "$PLATFORM:$MODE" in
  android:release) TARGET=(appbundle --release) ;;
  android:debug) TARGET=(apk --debug) ;;
  ios:release) TARGET=(ipa --release) ;;
  ios:debug) TARGET=(ios --debug --no-codesign) ;;
esac

flutter build "${TARGET[@]}" ${DEFINES[@]+"${DEFINES[@]}"} ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
