//
//  Response.swift
//
//
//  Created by Florian Claisse on 29/09/2023.
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
    /// Original response data.
    public let data: Data
    /// Completed task.
    public let task: URLSessionTask
    /// Task metrics collected for the request
    public let metrics: URLSessionTaskMetrics?
    
    /// Response HTTP status code.
    public var statusCode: Int? { (response as? HTTPURLResponse)?.statusCode }
    /// Original request.
    public var originalRequest: URLRequest? { task.originalRequest }
    /// The URL request object currently being handled by the task.
    /// May be different from the original request.
    public var currentRequest: URLRequest? { task.currentRequest }
    
    init(value: T, response: URLResponse, data: Data, task: URLSessionTask, metrics: URLSessionTaskMetrics? = nil) {
        self.value = value
        self.response = response
        self.data = data
        self.task = task
        self.metrics = metrics
    }
    
    /// Returns a response containing the mapped value.
    public func map<U>(_ closure: (T) throws -> U) rethrows -> Response<U> {
        Response<U>(value: try closure(value), response: response, data: data, task: task, metrics: metrics)
    }
}

extension Response where T == URL {
    /// The location of the downloaded file. Only applicable for requests
    /// performed using ``HTTPClient/download(for:delegate:configure:)``.
    public var location: URL { value }
}

extension Response: @unchecked Sendable where T: Sendable { }
