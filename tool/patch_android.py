#!/usr/bin/env python3
"""Idempotently patches android/app/src/main/AndroidManifest.xml for RoboLink:
INTERNET permission (required in release builds), cleartext HTTP to the local
device, and the app label."""
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1] if len(sys.argv) > 1
                    else "android/app/src/main/AndroidManifest.xml")
text = path.read_text(encoding="utf-8")

if "android.permission.INTERNET" not in text:
    text = re.sub(
        r"(<manifest[^>]*>)",
        r'\1\n    <uses-permission android:name="android.permission.INTERNET"/>'
        r'\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>',
        text, count=1)

if "usesCleartextTraffic" not in text:
    # Android 9+ blocks plain HTTP by default; the ESP8266 speaks plain HTTP on the LAN.
    text = text.replace("<application", '<application\n        android:usesCleartextTraffic="true"', 1)

text = re.sub(r'android:label="[^"]*"', 'android:label="RoboLink"', text, count=1)
path.write_text(text, encoding="utf-8")
print("patched", path)
