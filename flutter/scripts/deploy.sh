#!/usr/bin/env bash
# Build the Flutter app and publish it to Firebase App Distribution.
#
# Usage: scripts/deploy.sh [--platform android|ios|all] [--groups g1,g2]
#                          [--testers a@x.com,b@x.com] [--notes "text"]
#                          [--bump] [--skip-build] [--dry-run]
#
# Config comes from the environment or from scripts/.env.deploy (see
# scripts/.env.deploy.example). Flags override the file.
set -euo pipefail
cd "$(dirname "$0")/.."

PLATFORM="android"
NOTES=""
BUMP=false
SKIP_BUILD=false
DRY_RUN=false
CLI_GROUPS=""
CLI_TESTERS=""

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="${2:-}"; shift 2 ;;
    --platform=*) PLATFORM="${1#*=}"; shift ;;
    --groups) CLI_GROUPS="${2:-}"; shift 2 ;;
    --groups=*) CLI_GROUPS="${1#*=}"; shift ;;
    --testers) CLI_TESTERS="${2:-}"; shift 2 ;;
    --testers=*) CLI_TESTERS="${1#*=}"; shift ;;
    --notes) NOTES="${2:-}"; shift 2 ;;
    --notes=*) NOTES="${1#*=}"; shift ;;
    --bump) BUMP=true; shift ;;
    --skip-build) SKIP_BUILD=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
done

[[ "$PLATFORM" == "android" || "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]] \
  || { echo "Invalid --platform: $PLATFORM" >&2; usage; }

# ---- config -----------------------------------------------------------------
DEPLOY_ENV="scripts/.env.deploy"
if [[ -f "$DEPLOY_ENV" ]]; then
  # Don't let the file clobber values already exported in the shell.
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    value="${value%\"}"; value="${value#\"}"
    [[ -z "${!key:-}" ]] && export "$key=$value"
  done < "$DEPLOY_ENV"
fi

FIREBASE_GROUPS="${CLI_GROUPS:-${FIREBASE_GROUPS:-}}"
FIREBASE_TESTERS="${CLI_TESTERS:-${FIREBASE_TESTERS:-}}"
IOS_EXPORT_METHOD="${IOS_EXPORT_METHOD:-ad-hoc}"

# ---- preflight --------------------------------------------------------------
command -v firebase >/dev/null || { echo "firebase CLI not found. Install: npm i -g firebase-tools" >&2; exit 1; }
command -v flutter >/dev/null || { echo "flutter not found in PATH" >&2; exit 1; }

# Apps backed by Supabase ship .env.example.json and need .env.json; others build without defines.
DEFINES=()
if [[ -f .env.json ]]; then
  DEFINES=(--dart-define-from-file=.env.json)
elif [[ -f .env.example.json ]]; then
  echo "Missing .env.json. Run: cp .env.example.json .env.json" >&2; exit 1
fi

if [[ -z "$FIREBASE_GROUPS" && -z "$FIREBASE_TESTERS" ]]; then
  echo "Set FIREBASE_GROUPS and/or FIREBASE_TESTERS (or pass --groups/--testers)." >&2
  exit 1
fi

if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] && ! firebase projects:list >/dev/null 2>&1; then
  echo "Not authenticated. Run 'firebase login' (local) or set GOOGLE_APPLICATION_CREDENTIALS (CI)." >&2
  exit 1
fi

need_app_id() {
  local var="$1"
  [[ -n "${!var:-}" ]] || { echo "Missing $var (Firebase console > Project settings > Your apps > App ID)." >&2; exit 1; }
}
[[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]] && need_app_id FIREBASE_ANDROID_APP_ID
[[ "$PLATFORM" == "ios"     || "$PLATFORM" == "all" ]] && need_app_id FIREBASE_IOS_APP_ID

if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]] && [[ "$(uname)" != "Darwin" ]]; then
  echo "iOS builds require macOS." >&2; exit 1
fi

# ---- version bump (optional) ------------------------------------------------
if $BUMP; then
  current="$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+).*/\1+\2/p' pubspec.yaml)"
  [[ -n "$current" ]] || { echo "Could not parse version from pubspec.yaml" >&2; exit 1; }
  name="${current%+*}"; build="${current#*+}"
  next="$name+$((build + 1))"
  sed -i.bak -E "s/^version:.*/version: $next/" pubspec.yaml && rm -f pubspec.yaml.bak
  echo "Version: $current -> $next"
fi

# ---- release notes ----------------------------------------------------------
if [[ -z "$NOTES" ]]; then
  if NOTES="$(git log -5 --pretty='- %s' 2>/dev/null)" && [[ -n "$NOTES" ]]; then :; else NOTES="Build $(date '+%Y-%m-%d %H:%M')"; fi
fi

# ---- build + distribute -----------------------------------------------------
PROJECT_ARGS=()
[[ -n "${FIREBASE_PROJECT_ID:-}" ]] && PROJECT_ARGS=(--project "$FIREBASE_PROJECT_ID")

TARGET_ARGS=()
[[ -n "$FIREBASE_GROUPS" ]] && TARGET_ARGS+=(--groups "$FIREBASE_GROUPS")
[[ -n "$FIREBASE_TESTERS" ]] && TARGET_ARGS+=(--testers "$FIREBASE_TESTERS")

run() {
  if $DRY_RUN; then echo "[dry-run] $*"; else "$@"; fi
}

distribute() {
  local file="$1" app_id="$2"
  if ! $DRY_RUN && [[ ! -f "$file" ]]; then echo "Artifact not found: $file" >&2; exit 1; fi
  echo "Uploading $file ..."
  run firebase appdistribution:distribute "$file" \
    --app "$app_id" \
    ${PROJECT_ARGS[@]+"${PROJECT_ARGS[@]}"} \
    "${TARGET_ARGS[@]}" \
    --release-notes "$NOTES"
}

if ! $SKIP_BUILD; then run flutter pub get; fi

if [[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]]; then
  if [[ ! -f android/key.properties ]]; then
    echo "Warning: android/key.properties missing; APK will be signed with the debug key." >&2
  fi
  $SKIP_BUILD || run flutter build apk --release ${DEFINES[@]+"${DEFINES[@]}"}
  distribute "build/app/outputs/flutter-apk/app-release.apk" "$FIREBASE_ANDROID_APP_ID"
fi

if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]]; then
  $SKIP_BUILD || run flutter build ipa --release --export-method "$IOS_EXPORT_METHOD" ${DEFINES[@]+"${DEFINES[@]}"}
  IPA="$(ls -t build/ios/ipa/*.ipa 2>/dev/null | head -1 || true)"
  $DRY_RUN && IPA="build/ios/ipa/$(sed -n 's/^name:[[:space:]]*//p' pubspec.yaml).ipa"
  distribute "$IPA" "$FIREBASE_IOS_APP_ID"
fi

echo "Done."
