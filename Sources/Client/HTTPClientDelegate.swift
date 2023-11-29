//
//  HTTPClientDelegate.swift
//
//
//  Created by Florian Claisse on 29/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol HTTPClientDelegate {
    
    /// Allows you to modify the request right before it is sent.
    ///
    /// Gets called right before sending the request. If the retries are enabled,
    /// is called before every attempt.
    ///
    /// - Parameters:
    ///   - client: The client that sends the request.
    ///   - request: The request about to be sent. Can be modified
    func client(_ client: HTTPClient, willSendRequest request: inout URLRequest) async throws
    
    
    /// Validates response for the given request.
    ///
    /// - Parameters:
    ///   - client: The client that sent the request.
    ///   - response: The response with an invalid status code.
    ///   - data: Body of the response, if any.
    ///   - task: Failaid request.
    ///
    /// - Throws: An error to be returned to the user. By default, throws
    /// ``HTTPClientError/unacceptableStatusCode(_:)`` if the code is outside of
    /// the `200..<300` range.
    func client(_ client: HTTPClient, validateResponse response: HTTPURLResponse, data: Data, task: URLSessionTask) throws
    
    
    /// Gets called after a networking failure. Only one retry attempt is allowed.
    ///
    /// - Important: This method will only be called for network requests, but not for
    /// response body decoding failures or failures with creating request using
    /// ``client(_:makeURLForRequest:)-53a0i`` and ``client(_:willSendRequest:)-9l4ni``
    ///
    /// - Parameters:
    ///   - client: The client that sent the request.
    ///   - task: The failed task
    ///   - error: The encountered error
    ///   - attempts: The number of already performed attempts.
    ///
    /// - Returns: `true` to retry the request.
    func client(_ client: HTTPClient, shouldRetry task: URLSessionTask, error: Error, attempts: Int) async throws -> Bool
    
    /// Constructs URL for the given request.
    ///
    /// - Parameters:
    ///   - client: The client that sends the request.
    ///   - request: The request about to be sent.
    ///
    /// - Returns: The URL for the request. Return `nil` to use the default
    /// logic used by client.
    func client<T>(_ client: HTTPClient, makeURLForRequest request: Request<T>) throws -> URL?
    
    /// Allows you to override the client's encoder for a specific request.
    ///
    /// - Parameters:
    ///   - client: The client that sends the request.
    ///   - request: The request about to be sent.
    ///
    /// - Returns: The JSONEncoder for the request. Return `nil` to use the default
    /// encoder set in the client.
    func client<T>(_ client: HTTPClient, encoderForRequest request: Request<T>) -> JSONEncoder?
    
    /// Allows you to override the client's decoder for a specific request.
    ///
    /// - Parameters:
    ///   - client: The client that sends the request.
    ///   - request: The request that was performed.
    ///
    /// - Returns: The JSONDecoder for the request. Return `nil` to use the default
    /// decoder set in the client.
    func client<T>(_ client: HTTPClient, decoderForRequest request: Request<T>) -> JSONDecoder?
}

public extension HTTPClientDelegate {
    func client(_ client: HTTPClient, willSendRequest request: inout URLRequest) async throws {
        // Do nothind
    }
    
    func client(_ client: HTTPClient, validateResponse response: HTTPURLResponse, data: Data, task: URLSessionTask) throws {
        guard (200 ..< 300).contains(response.statusCode) else {
            throw HTTPClientError.unacceptableStatusCode(response.statusCode)
        }
    }
    
    func client(_ client: HTTPClient, shouldRetry task: URLSessionTask, error: Error, attempts: Int) async throws -> Bool {
        false // Disabled by default
    }
    
    func client<T>(_ client: HTTPClient, makeURLForRequest request: Request<T>) throws -> URL? {
        nil // Use default handling
    }
    
    func client<T>(_ client: HTTPClient, encoderForRequest request: Request<T>) -> JSONEncoder? {
        nil
    }
    
    func client<T>(_ client: HTTPClient, decoderForRequest request: Request<T>) -> JSONDecoder? {
        nil
    }
}
