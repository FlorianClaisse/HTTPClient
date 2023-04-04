# Integrations

Learn how to extend ``HTTPClient`` using third-party frameworks.

### CreateAPI

With [CreateAPI](https://github.com/CreateAPI/CreateAPI), you can take your backend OpenAPI spec, and generate all of the response entities and even requests for ``HTTPClient``.

```swift
generate api.github.yaml --output ./OctoKit --module "OctoKit"
```

> Check out [App Store Connect Swift SDK](https://github.com/AvdLee/appstoreconnect-swift-sdk) that uses [CreateAPI](https://github.com/CreateAPI/CreateAPI) for code generation.

### Other Extensions

HTTPClient is a lean framework with a lot of flexibility and customization points. It makes it very easy to learn and use, but you'll need to install additional modules for certain features.

- [Mocker](https://github.com/WeTransfer/Mocker) – mocking network requests for testing purposes
- [URLQueryEncoder](https://github.com/CreateAPI/URLQueryEncoder) – URL query encoder with `Codable` support
- [MultipartFormDataKit](https://github.com/Kuniwak/MultipartFormDataKit) – adds support for `multipart/form-data`
- [NaiveDate](https://github.com/CreateAPI/NaiveDate) – working with dates without timezones
