import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Performs network requests contructed using ``Request``
public actor HTTPClient {
    /// The configuration with which the client was initialized with.
    public nonisolated let configuration: Configuration
    /// The underlying `URLSession` instance.
    public nonisolated let session: URLSession
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let delegate: HTTPClientDelegate
    private let dataLoader = DataLoader()
    
    // MARK: - Initializers
    
#if swift(>=5.7)
    /// Initializes the client with the given parameters.
    ///
    /// - Parameters:
    ///   - baseURL: A base URL. For exemple, `"https://api.github.com"`
    ///   - coonfigure: Updates the client configuration.
    public init(baseURL: URL?, _ configure: @Sendable (inout Configuration) -> Void = { _ in }) {
        var configuration = Configuration(baseURL: baseURL)
        configure(&configuration)
        self.init(configuration: configuration)
    }
#else
    /// Initializes the client with the given parameters.
    ///
    /// - Parameters:
    ///   - baseURL: A base URL. For exemple `"https://api.github.com"`
    ///   - configure: Updates the client configuration.
    public convenience init(baseURL: URL?, _ configure: (inout Configuration) -> Void = { _ in }) {
        var configuration = Configuration(baseURL: baseURL)
        configure(&configuration)
        self.init(configuration: configuration)
    }
#endif
    
    /// Initializes the client with the given configuration.
    public init(configuration: Configuration) {
        self.configuration = configuration
        let delegateQueue = configuration.sessionDelegateQueue ?? .serial()
        self.session = URLSession(configuration: configuration.sessionConfiguration, delegate: dataLoader, delegateQueue: delegateQueue)
        self.dataLoader.userSessionDelegate = configuration.sessionDelegate
        self.delegate = configuration.delegate ?? DefaultHTTPClientDelegate()
        self.decoder = configuration.decoder
        self.encoder = configuration.encoder
    }
}

// MARK: - Sending Requests

extension HTTPClient {
    
    /// Sends the given request and returns a decoded response.
    ///
    /// - Parameters:
    ///   - request: The request to perform.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// - Returns: A response with a decoded body. If the response type is
    /// optional and the response body is empty, return `nil`.
    @discardableResult public func send<T: Decodable>(_ request: Request<T>, delegate: URLSessionDataDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<T> {
        let response = try await data(for: request, delegate: delegate, configure: configure)
        let decoder = self.delegate.client(self, decoderForRequest: request) ?? self.decoder
        let value: T = try await decode(response.data, using: decoder)
        return response.map { _ in value }
    }
    
    /// Sends the given request.
    ///
    /// - Parameters:
    ///   - request: The request to perform.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// - Returns: A response with an empty value.
    @discardableResult public func send(_ request: Request<Void>, delegate: URLSessionDataDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<Void> {
        try await data(for: request, delegate: delegate, configure: configure).map { _ in () }
    }
}

// MARK: - Fetching Data

extension HTTPClient {
    
    /// Fatches data for the given request.
    ///
    /// - Parameters:
    ///   - request: The request to perform.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// - Returns: A response with a raw response data.
    public func data<T>(for request: Request<T>, delegate: URLSessionDataDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<Data> {
        let request = try await makeURLRequest(for: request, configure)
        return try await performRequest {
            var request = request
            
            try await self.delegate.client(self, willSendRequest: &request)
            
            let task = session.dataTask(with: request)
            do {
                let response = try await dataLoader.startDataTask(task, session: session, delegate: delegate)
                try validate(response)
                return response
            } catch {
                throw DataLoaderError(task: task, error: error)
            }
        }
    }
}

// MARK: - Downloads
#if !os(Linux)
extension HTTPClient {
    
    /// Downloads the requested data to a file.
    ///
    /// - Parameters:
    ///   - request: A request object that provides the URL and other parameters.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// - Returns: A response with the location of the downloaded file. The file
    /// will not be removed automatically until the app restarts. Make sure to
    /// move file to a known lcoation in your app.
    public func download<T>(for request: Request<T>, delegate: URLSessionDownloadDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<URL> {
        var urlRequest = try await makeURLRequest(for: request, configure)
        try await self.delegate.client(self, willSendRequest: &urlRequest)
        let task = session.downloadTask(with: urlRequest)
        return try await _startDownloadTask(task, delegate: delegate)
    }
    
    /// Resumes the download from the given resume data.
    ///
    /// - Parameters:
    ///   - delegate: A task-specific delegate.
    public func downlaod(resumeFrom resumeData: Data, delegate: URLSessionDownloadDelegate? = nil) async throws -> Response<URL> {
        let task = session.downloadTask(withResumeData: resumeData)
        return try await _startDownloadTask(task, delegate: delegate)
    }
    
    private func _startDownloadTask(_ task: URLSessionDownloadTask, delegate: URLSessionDownloadDelegate?) async throws -> Response<URL> {
        let response = try await dataLoader.startDownloadTask(task, session: session, delegate: delegate)
        try validate(response)
        return response
    }
}
#endif

// MARK: - Upload

extension HTTPClient {
    
    /// Convenience method to upload data from a file.
    ///
    /// - Parameters:
    ///   - request: The URLRequest for which to upload data.
    ///   - fileURL: File to upload.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// - Returns: A response with a decoded body. If the response type is
    /// optional and the response body is empty, returns `nil`.
    @discardableResult public func upload<T: Decodable>(for request: Request<T>, fromFile fileURL: URL, delegate: URLSessionTaskDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<T> {
        let response =  try await _upload(for: request, fromFile: fileURL, delegate: delegate, configure: configure)
        let decoder = self.delegate.client(self, decoderForRequest: request) ?? self.decoder
        let value: T = try await decode(response.data, using: decoder)
        return response.map { _ in value }
    }
    
    /// Convenience method to upload data from a file.
    ///
    /// - Parameters:
    ///   - request: The URLRequest for which to upload data.
    ///   - fileURL: File to upload.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// - Returns: Empty response.
    @discardableResult public func upload(for request: Request<Void>, fromFile fileURL: URL, delegate: URLSessionTaskDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<Void> {
        try await _upload(for: request, fromFile: fileURL, delegate: delegate, configure: configure).map { _ in () }
    }
    
    private func _upload<T>(for request: Request<T>, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?, configure: ((inout URLRequest) throws -> Void)?) async throws -> Response<Data> {
        let request = try await makeURLRequest(for: request, configure)
        return try await performRequest {
            var request = request
            try await self.delegate.client(self, willSendRequest: &request)
            let task = session.uploadTask(with: request, fromFile: fileURL)
            
            do {
                let response = try await dataLoader.startUploadTask(task, session: session, delegate: delegate)
                try validate(response)
                return response
            } catch {
                throw DataLoaderError(task: task, error: error)
            }
        }
    }
}

// MARK: - Upload Data

extension HTTPClient {
    
    /// Convenience method for uploading data.
    ///
    /// - parameters:
    ///   - request: The URLRequest for which to upload data.
    ///   - data: Data to upload.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// - returns: A response with a decoded body. If the response type is
    /// optional and the response body is empty, returns `nil`.
    @discardableResult public func upload<T: Decodable>(for request: Request<T>, from data: Data, delegate: URLSessionTaskDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<T> {
        let response = try await _upload(for: request, from: data, delegate: delegate, configure: configure)
        let decoder = self.delegate.client(self, decoderForRequest: request) ?? self.decoder
        let value: T = try await decode(response.data, using: decoder)
        return response.map { _ in value }
    }
    
    /// Convenience method for uploading data.
    ///
    /// - parameters:
    ///   - request: The URLRequest for which to upload data.
    ///   - data: Data to upload.
    ///   - delegate: A task-specific delegate.
    ///   - configure: Modifies the underlying `URLRequest` before sending it.
    ///
    /// Returns decoded response.
    @discardableResult public func upload(for request: Request<Void>, from data: Data, delegate: URLSessionTaskDelegate? = nil, configure: ((inout URLRequest) throws -> Void)? = nil) async throws -> Response<Void> {
        try await _upload(for: request, from: data, delegate: delegate, configure: configure).map { _ in () }
    }
    
    private func _upload<T>(for request: Request<T>, from data: Data, delegate: URLSessionTaskDelegate?, configure: ((inout URLRequest) throws -> Void)?) async throws -> Response<Data> {
        let request = try await makeURLRequest(for: request, configure)
        return try await performRequest {
            var request = request
            try await self.delegate.client(self, willSendRequest: &request)
            let task = session.uploadTask(with: request, from: data)
            do {
                let response = try await dataLoader.startUploadTask(task, session: session, delegate: delegate)
                try validate(response)
                return response
            } catch {
                throw DataLoaderError(task: task, error: error)
            }
        }
    }
}

// MARK: - Making Requests

extension HTTPClient {
    
    /// Creates `URLRequest` for the given request.
    public func makeURLRequest<T>(for request: Request<T>) async throws -> URLRequest {
        try await makeURLRequest(for: request, { _ in })
    }
    
    private func makeURLRequest<T>(for request: Request<T>, _ configure: ((inout URLRequest) throws -> Void)?) async throws -> URLRequest {
        let url = try makeURL(for: request)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpMethod = request.method.rawValue
        
        if let body = request.body {
            let encoder = delegate.client(self, encoderForRequest: request) ?? self.encoder
            urlRequest.httpBody = try await encode(body, using: encoder)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil && session.configuration.httpAdditionalHeaders?["Content-Type"] == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        if urlRequest.value(forHTTPHeaderField: "Accept") == nil && session.configuration.httpAdditionalHeaders?["Accept"] == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        if let configure = configure {
            try configure(&urlRequest)
        }
        
        return urlRequest
    }
    
    private func makeURL<T>(for request: Request<T>) throws -> URL {
        if let url = try delegate.client(self, makeURLForRequest: request) {
            return url
        }
        
        func makeURL() -> URL? {
            guard let url = request.url else { return nil }
            return url.scheme == nil ? configuration.baseURL?.appendingPathComponent(url.absoluteString) : url
        }
        
        guard let url = makeURL(), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        
        if let query = request.query, !query.isEmpty {
            components.queryItems = query.map(URLQueryItem.init)
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        return url
    }
}

// MARK: - Helpers

extension HTTPClient {
    
    private func performRequest<T>(attemps: Int = 1, send: () async throws -> T) async throws -> T {
        do {
            return try await send()
        } catch {
            guard let error = error as? DataLoaderError else { throw error }
            guard try await delegate.client(self, shouldRetry: error.task, error: error.error, attempts: attemps) else {
                throw error.error
            }
            
            return try await performRequest(attemps: attemps + 1, send: send)
        }
    }
    
    private func validate<T>(_ response: Response<T>) throws {
        guard let httpResponse = response.response as? HTTPURLResponse else { return }
        try delegate.client(self, validateResponse: httpResponse, data: response.data, task: response.task)
    }
}

// MARK: - Configuration

extension HTTPClient {
    /// The configuration for ``HTTPClient``
    public struct Configuration: @unchecked Sendable {
        /// A base URL. For exemple `"https://api.github.com"`.
        public var baseURL: URL?
        /// The client delegate. The client holds a string reference to it.
        public var delegate: HTTPClientDelegate?
        /// By default, `URLSessionConfiguration.default`
        public var sessionConfiguration: URLSessionConfiguration = .default
        /// The (optional) URLSession delegate that allows you to monitor the underlying URLSession.
        public var sessionDelegate: URLSessionDelegate?
        /// Overrides the default delegate queue.
        public var sessionDelegateQueue: OperationQueue?
        /// By default, uses `.iso8601` date decoding startegy.
        public var decoder: JSONDecoder
        /// By default, uses `.iso8601` date encoding startegy.
        public var encoder: JSONEncoder
        
        /// Initializes the configuration.
        public init(baseURL: URL? = nil, delegate: HTTPClientDelegate? = nil, sessionConfiguration: URLSessionConfiguration = .default) {
            self.baseURL = baseURL
            self.delegate = delegate
            self.sessionConfiguration = sessionConfiguration
            self.decoder = JSONDecoder()
            self.decoder.dateDecodingStrategy = .iso8601
            self.encoder = JSONEncoder()
            self.encoder.dateEncodingStrategy = .iso8601
        }
    }
}
