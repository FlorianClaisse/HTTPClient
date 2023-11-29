//
//  HTTPClientError.swift
//  
//
//  Created by Florian Claisse on 02/10/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum HTTPClientError: Error, LocalizedError {
    case unacceptableStatusCode(Int)
    
    public var errorDescription: String? {
        switch self {
        case .unacceptableStatusCode(let statusCode): return "Response status code was unacceptable: \(statusCode)"
        }
    }
}
