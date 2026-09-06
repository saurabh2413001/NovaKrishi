#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter is not installed or is not on PATH.'
  exit 1
fi

if [ ! -f pubspec.yaml ]; then
  echo 'Run this script from the NovaKrishi project root (where pubspec.yaml exists).'
  exit 1
fi

flutter create --platforms=android .
flutter pub get

echo
echo 'Android platform is ready.'
echo 'Run: flutter devices'
echo 'Then: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api'
