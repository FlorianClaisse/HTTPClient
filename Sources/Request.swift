//
//  Request.swift
//
//
//  Created by Florian Claisse on 29/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// An HTTP network request.
public struct Request<Response>: @unchecked Sendable {
    /// HTTP method, e.g "GET"
    public var method: HTTPMethod
    /// Resource URL. Can be either obsolute or relative.
    public var url: URL?
    /// Request query items.
    public var query: [(String, String?)]?
    /// Request body.
    public var body: Encodable?
    /// Request headers to be added to the request.
    public var headers: [String: String]?
    /// ID provided by the user. Not used by the API client.
    public var id: String?
    
    /// Initialiazes the request with the given parameters.
    public init(url: URL, method: HTTPMethod = .get, query: [(String, String?)]? = nil, body: Encodable? = nil, headers: [String: String]? = nil, id: String? = nil) {
        self.method = method
        self.url = url
        self.query = query
        self.body = body
        self.headers = headers
        self.id = id
    }
    
    /// Initializes the request with the given parameters.
    public init(path: String, method: HTTPMethod = .get, query: [(String, String?)]? = nil, body: Encodable? = nil, headers: [String: String]? = nil, id: String? = nil) {
        self.method = method
        self.url = URL(string: path.isEmpty ? "/" : path)
        self.query = query
        self.body = body
        self.headers = headers
        self.id = id
    }
    
    private init(optionalURL: URL?, method: HTTPMethod) {
        self.url = optionalURL
        self.method = method
    }
    
    /// Changes the response type keeping the rest of the request parameters.
    public func withResponse<T>(_ type: T.Type) -> Request<T> {
        var copy = Request<T>(optionalURL: url, method: method)
        copy.query = query
        copy.body = body
        copy.headers = headers
        copy.id = id
        return copy
    }
}

extension Request where Response == Void {
    /// Initialiazes the request with the given parameters.
    public init(url: URL, method: HTTPMethod = .get, query: [(String, String?)]? = nil, body: Encodable? = nil, headers: [String: String]? = nil, id: String? = nil) {
        self.method = method
        self.url = url
        self.query = query
        self.headers = headers
        self.body = body
        self.id = id
    }
    
    public init(path: String, method: HTTPMethod = .get, query: [(String, String?)]? = nil, body: Encodable? = nil, headers: [String: String]? = nil, id: String? = nil) {
        self.method = method
        self.url = URL(string: path.isEmpty ? "/" : path)
        self.query = query
        self.body = body
        self.headers = headers
        self.id = id
    }
}
