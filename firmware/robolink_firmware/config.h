// RoboLink firmware configuration (no secrets here — see secrets.h).
#pragma once

#define FIRMWARE_VERSION "1.0.0"
#define DEVICE_ID        "robolink-001"
#define HOSTNAME         "robolink"
#define HTTP_PORT        80

// ---- Relay wiring --------------------------------------------------------
// Wemos D1 mini relay shield uses D1 (GPIO5). D1 is not a boot-strapping pin.
// Avoid D3 (GPIO0), D4 (GPIO2) and D8 (GPIO15) for relays: they influence boot.
#define RELAY_PIN D1

// 1 = relay board is active-LOW (IN pin LOW switches the relay ON).
// Most 1-channel relay modules with an optocoupler are active-LOW; the Wemos
// relay shield is active-HIGH. Check yours with a low-voltage load first.
#define RELAY_ACTIVE_LOW 0

// State applied immediately at power-up / reset, before Wi-Fi starts.
// 0 = OFF (recommended, safe). The firmware never restores the last state.
#define RELAY_INITIAL_STATE_ON 0
