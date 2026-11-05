#!/usr/bin/env bash
# Usage: scripts/build.sh [--platform android|ios] [--mode debug|release] [--bundle apk|appbundle] [extra flutter build args]
set -euo pipefail
cd "$(dirname "$0")/.."

PLATFORM="android"
MODE="release"
BUNDLE="apk"
BUNDLE_SET=false
EXTRA_ARGS=()

usage() {
  echo "Usage: $0 [--platform android|ios] [--mode debug|release] [--bundle apk|appbundle] [extra flutter build args]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="${2:-}"; shift 2 ;;
    --platform=*) PLATFORM="${1#*=}"; shift ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --mode=*) MODE="${1#*=}"; shift ;;
    --bundle) BUNDLE="${2:-}"; BUNDLE_SET=true; shift 2 ;;
    --bundle=*) BUNDLE="${1#*=}"; BUNDLE_SET=true; shift ;;
    -h|--help) usage ;;
    *) EXTRA_ARGS+=("$1"); shift ;;
  esac
done

[[ "$PLATFORM" == "android" || "$PLATFORM" == "ios" ]] || { echo "Invalid --platform: $PLATFORM" >&2; usage; }
[[ "$MODE" == "debug" || "$MODE" == "release" ]] || { echo "Invalid --mode: $MODE" >&2; usage; }
[[ "$BUNDLE" == "apk" || "$BUNDLE" == "appbundle" ]] || { echo "Invalid --bundle: $BUNDLE" >&2; usage; }
[[ "$BUNDLE_SET" == false || "$PLATFORM" == "android" ]] || { echo "--bundle only applies to --platform android" >&2; usage; }

DEFINES=()

flutter pub get

case "$PLATFORM:$MODE" in
  android:*) TARGET=("$BUNDLE" "--$MODE") ;;
  ios:release) TARGET=(ipa --release) ;;
  ios:debug) TARGET=(ios --debug --no-codesign) ;;
esac

flutter build "${TARGET[@]}" ${DEFINES[@]+"${DEFINES[@]}"} ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}
