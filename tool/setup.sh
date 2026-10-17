#!/usr/bin/env bash
# Generates the Android platform files and applies RoboLink's manifest patch.
# Run from the project root with Flutter >= 3.22 installed.
set -euo pipefail

if [ ! -d android ]; then
  TMP="$(mktemp -d)"
  flutter create --platforms=android --org ir.roboram --project-name robolink "$TMP/robolink"
  cp -r "$TMP/robolink/android" ./android
  rm -rf "$TMP"
fi
python3 tool/patch_android.py android/app/src/main/AndroidManifest.xml
flutter pub get
echo "Setup done. Next: flutter analyze && flutter test && flutter run"
