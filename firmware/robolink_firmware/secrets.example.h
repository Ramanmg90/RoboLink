// Copy this file to secrets.h and fill in your values. secrets.h is git-ignored.
#pragma once

#define WIFI_SSID     "your-wifi-name"
#define WIFI_PASSWORD "your-wifi-password"

// Optional API token. Leave "" to disable authentication (LAN only!).
// If set, the app must send the same value in the device's token field and
// requests carry:  Authorization: Bearer <token>
#define AUTH_TOKEN ""
