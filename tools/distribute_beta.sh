#!/usr/bin/env bash

set -Eeuo pipefail

project_id="pet-fiasco-live-2026"
group_alias="pet-fiasco-beta"
android_app_id="1:383935377007:android:84ffb3707a31d32606e79a"
ios_app_id="1:383935377007:ios:078174c3565282a206e79a"

usage() {
  echo "Usage: $0 android path/to/app.apk [release notes]" >&2
  echo "       $0 ios path/to/signed-beta.ipa [release notes]" >&2
  exit 2
}

platform="${1:-}"
binary="${2:-}"
notes="${3:-Pet Fiasco beta build}"

[[ -n "$platform" && -n "$binary" ]] || usage
[[ -f "$binary" ]] || { echo "Beta file not found: $binary" >&2; exit 1; }

case "$platform" in
  android)
    [[ "$binary" == *.apk ]] || { echo "Android beta must be an APK." >&2; exit 1; }
    app_id="$android_app_id"
    ;;
  ios)
    [[ "$binary" == *.ipa ]] || { echo "iOS beta must be an IPA." >&2; exit 1; }
    if ! unzip -l "$binary" | grep -q 'embedded.mobileprovision'; then
      echo "Firebase App Distribution requires a signed iOS IPA with an embedded provisioning profile." >&2
      echo "The public Sideloadly IPA is intentionally unsigned and cannot be used here." >&2
      exit 1
    fi
    app_id="$ios_app_id"
    ;;
  *)
    usage
    ;;
esac

firebase appdistribution:distribute "$binary" \
  --project "$project_id" \
  --app "$app_id" \
  --groups "$group_alias" \
  --release-notes "$notes"
