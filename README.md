# HTTPClient

[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-4E4E4E.svg?colorA=28a745)](#installation)

A lean Swift web API Client built using async/await

HTTPClient provides a clear convenient API modeling network request using `Request<Response>` type. And its `HTTPClient` makes it easy to execute these requests and decode the responses.

```swift
// Create a client
let client = HTTPClient(baseURL: URL(string: "https://api.github.com"))

// Start sending requests
let user: User = try await client.send(Request(path: "/user")).value

var request = Request(path: "/user/emails", method: .post, body: ["flo@me.com"])
try await client.send(request)
```

The client uses `URLSession` for networking and provides complete access to all its APIs. It is designed with the "less is more" idea in mind and doesn't introduce any unnecessary abstractions on top of native APIs.

```swift
// In addition to `HTTPClientDelegate`, you can also override any methods
// from `URLSessionDelegate` family of APIs.
let client = APIClient(baseURL: URL(string: "https://api.github.com")) {
    $0.sessionDelegate = ...
}

// You can also provide task-specific delegates and easily change any of
// the `URLRequest` properties before the request is sent.
let delegate: URLSessionDataDelegate = ...
let response = try await client.send(Paths.user.get, delegate: delegate) {
    $0.cachePolicy = .reloadIgnoringLocalCacheData
}
```

In addition to sending quick requests, it also supports downloading data to a file, uploading from file, authentication, auto-retries, logging and more, It's a kind if code that you would typically write on top of `URLSession` if you were using it directly.

## Documentation

Learn how to use HTTPClient by going the [documentation](http://todo) created using DocC.

To learn more about `URLSession`, see [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system).

## Integrations


### CreateAPI

With [CreateAPI](https://github.com/CreateAPI/CreateAPI), you can take backend OpenAPI spec, and generate all of the response entities and even requests for HTTPClient `HTTPClient`.

```swift
generate api.github.yaml --output ./OctoKit -- module "OctoKit"
```

> Check out [App Store Connect Swift SDK](https://github.com/AvdLee/appstoreconnect-swift-sdk) that uses [CreateAPI](https://github.com/kean/CreateAPI) for code generation.

### Other Extensions

HTTPClient is a lean framework with a lot of flexibility and customization points. It makes it very easy to learn and use, but you'll need to install additional modules for certain features.

- [Mocker](https://github.com/WeTransfer/Mocker) – mocking network requests for testing purposes
- [URLQueryEncoder](https://github.com/CreateAPI/URLQueryEncoder) – URL query encoder with `Codable` support
- [MultipartFormDataKit](https://github.com/Kuniwak/MultipartFormDataKit) – adds support for `multipart/form-data`
- [NaiveDate](https://github.com/CreateAPI/NaiveDate) – working with dates without timezones

## Minimum Requirements
| HTTPClient  | Date         | Swift | Xcode | Platforms                                            |
|-------------|--------------|-------|-------|------------------------------------------------------|
| 1.0         | Apr 03, 2023 | 5.5   | 13.3  | iOS 13.0, watchOS 6.0, macOS 10.15, tvOS 13.0, Linux |
