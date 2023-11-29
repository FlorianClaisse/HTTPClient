//
//  HTTPMethod.swift
//
//
//  Created by Florian Claisse on 29/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct HTTPMethod: RawRepresentable, Hashable, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    
    public static let get: Self = "GET"
    public static let post: Self = "POST"
    public static let patch: Self = "PATCH"
    public static let put: Self = "PUT"
    public static let delete: Self = "DELETE"
    public static let options: Self = "OPTIONS"
    public static let head: Self = "HEAD"
    public static let trace: Self = "TRACE"
}
