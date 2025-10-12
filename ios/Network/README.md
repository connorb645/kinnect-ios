# Network

Suggested layout:
- `HTTP`: Low-level HTTP client, request/response models, interceptors.
- `API`: Endpoint definitions and high-level API client(s).
- `Models`: Network DTOs for decoding/encoding payloads.
- `Middleware`: Auth refresh, logging, retry, reachability, etc.

