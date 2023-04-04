//
//  Response.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A response with an associated value and metadata.
public struct Response<T> {
    /// Decoded response value.
    public let value: T
    /// Original response.
    public let response: URLResponse
    /// Original response Data
    public let data: Data
    /// Completed task.
    public let task: URLSessionTask
    /// Task metrics collected for the request.
    public let metrics: URLSessionTaskMetrics?
    
    /// Original request.
    public var originalRequest: URLRequest? { task.originalRequest }
    /// The URL request object currently being handled by the task. May be
    /// different from the original request.
    public var currentRequest: URLRequest? { task.currentRequest }
    /// Response HTTP status code.
    public var statusCode: Int? { (response as? HTTPURLResponse)?.statusCode }
    
    /// Initializes the response.
    public init(value: T, data: Data, response: URLResponse, task: URLSessionTask, metrics: URLSessionTaskMetrics? = nil) {
        self.value = value
        self.response = response
        self.data = data
        self.task = task
        self.metrics = metrics
    }
    
    /// Returns a response containing the mapped value.
    public func map<U>(_ closure: (T) throws -> U) rethrows -> Response<U> {
        Response<U>(value: try closure(value), data: data, response: response, task: task, metrics: metrics)
    }
}

extension Response where T == URL {
    /// The location of the downloaded file. Only applicable for requests
    /// performed using ``HTTPClient/download(for:delegate:configure:)``.
    public var location: URL { value }
}

extension Response: @unchecked Sendable where T: Sendable { }
