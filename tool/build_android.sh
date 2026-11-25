#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f android/key.properties ]]; then
  echo "缺少 android/key.properties。先复制 android/key.properties.example 并填写签名信息。" >&2
  exit 1
fi

flutter pub get
flutter analyze
flutter test
flutter build apk --release

echo
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
