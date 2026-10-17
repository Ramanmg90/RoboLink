# RoboLink local HTTP API (v1)

Base URL: `http://<device-ip>:80` — local network only. Never forward this port on the router.

Optional authentication: when `AUTH_TOKEN` is set in `secrets.h`, every request must carry
`Authorization: Bearer <token>`; otherwise the device answers `401`.

## GET /api/status
```
curl http://192.168.1.50/api/status
{"deviceId":"robolink-001","online":true,"relay":"OFF","firmwareVersion":"1.0.0"}
```
`relay` is exactly `"ON"` or `"OFF"`. The app rejects any other shape as malformed.

## POST /api/relay
```
curl -X POST http://192.168.1.50/api/relay -H "Content-Type: application/json" -d '{"state":"ON"}'
{"success":true,"relay":"ON"}
```
Errors:
| Code | Body |
|---|---|
| 400 | `{"success":false,"error":"state must be ON or OFF"}` / `"missing body"` |
| 401 | `{"success":false,"error":"unauthorized"}` |
| 404 | `{"success":false,"error":"not found"}` |

The app treats a command as successful only after (1) `success:true`, then (2) a fresh
`GET /api/status` reporting the requested relay state.
