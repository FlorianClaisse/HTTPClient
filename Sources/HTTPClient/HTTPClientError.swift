//
//  HTTPClientError.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Represents an error encountered by the client.
public enum HTTPClientError: Error, LocalizedError {
    case unacceptableStatusCode(Int)
    
    public var errorDescription: String? {
        switch self {
        case .unacceptableStatusCode(let statusCode):
            return "Response status code was unacceptable: \(statusCode)."
        }
    }
}
