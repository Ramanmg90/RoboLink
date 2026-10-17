/*
  RoboLink firmware v1.0.0 — Wemos D1 mini (ESP8266) + 1-channel relay.

  API (JSON, local network only):
    GET  /api/status -> {"deviceId":"robolink-001","online":true,"relay":"OFF","firmwareVersion":"1.0.0"}
    POST /api/relay   {"state":"ON"|"OFF"} -> {"success":true,"relay":"ON"}
  Errors: 400 {"success":false,"error":"..."}, 401 {"success":false,"error":"unauthorized"}

  Build: Arduino IDE / arduino-cli with the "esp8266 by ESP8266 Community" core
  (board: LOLIN(WEMOS) D1 R2 & mini). No extra libraries are required.
*/
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>

#include "config.h"
#include "secrets.h"

ESP8266WebServer server(HTTP_PORT);
bool relayOn = (RELAY_INITIAL_STATE_ON != 0);
unsigned long lastReconnectTry = 0;

// Pin level for a given logical state, honouring active-LOW boards.
uint8_t levelFor(bool on) {
  const bool activeLow = (RELAY_ACTIVE_LOW != 0);
  return (on != activeLow) ? HIGH : LOW;
}

void applyRelay() { digitalWrite(RELAY_PIN, levelFor(relayOn)); }

String relayStr() { return relayOn ? "ON" : "OFF"; }

void sendJson(int code, const String &body) {
  server.sendHeader("Cache-Control", "no-store");
  server.send(code, "application/json", body);
}

void sendError(int code, const char *msg) {
  sendJson(code, String("{\"success\":false,\"error\":\"") + msg + "\"}");
}

bool isAuthorized() {
  const String token = AUTH_TOKEN;
  if (token.length() == 0) return true;
  const String got = server.header("Authorization");
  const String expected = "Bearer " + token;
  if (got.length() != expected.length()) return false;
  uint8_t diff = 0;  // constant-time compare
  for (size_t i = 0; i < got.length(); i++) diff |= (uint8_t)(got[i] ^ expected[i]);
  return diff == 0;
}

// Minimal parser for {"state":"ON"} — avoids an extra JSON dependency.
bool parseState(const String &body, bool &on) {
  int k = body.indexOf("\"state\"");
  if (k < 0) return false;
  int c = body.indexOf(':', k);
  if (c < 0) return false;
  int q1 = body.indexOf('"', c);
  if (q1 < 0) return false;
  int q2 = body.indexOf('"', q1 + 1);
  if (q2 < 0) return false;
  String v = body.substring(q1 + 1, q2);
  v.trim();
  v.toUpperCase();
  if (v == "ON") { on = true; return true; }
  if (v == "OFF") { on = false; return true; }
  return false;
}

void handleStatus() {
  if (!isAuthorized()) { sendError(401, "unauthorized"); return; }
  sendJson(200, String("{\"deviceId\":\"") + DEVICE_ID +
                    "\",\"online\":true,\"relay\":\"" + relayStr() +
                    "\",\"firmwareVersion\":\"" + FIRMWARE_VERSION + "\"}");
}

void handleRelay() {
  if (!isAuthorized()) { sendError(401, "unauthorized"); return; }
  if (!server.hasArg("plain")) { sendError(400, "missing body"); return; }
  bool on;
  if (!parseState(server.arg("plain"), on)) { sendError(400, "state must be ON or OFF"); return; }
  relayOn = on;
  applyRelay();
  Serial.printf("Relay -> %s\n", relayStr().c_str());
  sendJson(200, String("{\"success\":true,\"relay\":\"") + relayStr() + "\"}");
}

void setup() {
  // SAFE START: set the output level BEFORE enabling the pin as OUTPUT, and
  // do it before Wi-Fi/Serial so the relay never follows network activity.
  digitalWrite(RELAY_PIN, levelFor(relayOn));
  pinMode(RELAY_PIN, OUTPUT);

  Serial.begin(115200);
  Serial.println();
  Serial.println("RoboLink firmware " FIRMWARE_VERSION);

  WiFi.mode(WIFI_STA);
  WiFi.hostname(HOSTNAME);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 20000) {
    delay(300);
    Serial.print('.');
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());   // <- enter this address in the app
  } else {
    Serial.println("Wi-Fi not connected yet; will keep retrying. Relay stays in its safe state.");
  }

  MDNS.begin(HOSTNAME);  // optional: robolink.local (not reliable on all Android versions)

  static const char *headers[] = {"Authorization"};
  server.collectHeaders(headers, 1);
  server.on("/api/status", HTTP_GET, handleStatus);
  server.on("/api/relay", HTTP_POST, handleRelay);
  server.onNotFound([]() { sendError(404, "not found"); });
  server.begin();
}

void loop() {
  server.handleClient();
  MDNS.update();
  if (WiFi.status() != WL_CONNECTED && millis() - lastReconnectTry > 10000) {
    lastReconnectTry = millis();
    WiFi.reconnect();
  }
}
