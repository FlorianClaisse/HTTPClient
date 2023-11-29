# ``HTTPClient``

A lean Swift web API client built using async/await.

## Overview

HTTPClient provides a clear and convenient API for modeling network requests using `Request<Response>` type. And its `HTTPClient` makes it easy to execute these requests and decode the responses.

```swift
// Create a client
let client = HTTPClient(baseURL: URL(string: "https://api.github.com"))

// Start sending requests
let user: User = try await client.send(.get("/user")).value
try await client.send(.post("/user/emails", body: ["florian@exemple.com"]))
```

The client uses `URLSession` for networking and provides complete access to all its APIs. It is designed with the "less is more" idea in mind and doesn't introduce any unnecessary abstractions on top of native APIs.

```swift
// In addition to `HTTPClientDelegate`, you can also override any methods
// from `URLSessionDelegate` family of APIs.
let client = HTTPClient(baseURL: URL(string("https://api.github.com")) {
    $0.sessionDelegate = ...
}

// You can also provide task-specific delegates and easily change any of
// the `URLRequest` properties before the request is sent.
let delegate: URLSessionDataDelagete = ...
let response = try await client.send(Paths.user.get, delegate: delegate) {
    $0.cachePolicy = .reloadIgnoringLocalCacheData
}
```

In addition to sending quick requests, HTTPClient also supports downloads, uploads from file, authentication, auto-retries, logging, and more.

## Minimum Requirements

| HTTPClient | Date       | Swift | Xcode | Platforms                                            |
|------------|------------|-------|-------|------------------------------------------------------|
| 1.0        |            | 5.5   | 13.3  | iOS 13.0, watchOS 6.0, macOS 10.15, tvOS 13.0, Linux |

## Topics

### Essentials

- ``HTTPClient``
- ``Request``
- ``Response``

### Misc

- ``HTTPClientError``
- ``HTTPClientDelegate``
- ``HTTPMethod``

### Unused

- ``HTTPMediaType``

### Articles

- <doc:Define-API>
- <doc:Authentication>
- <doc:Caching>
