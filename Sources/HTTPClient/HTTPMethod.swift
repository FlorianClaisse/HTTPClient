//
//  HTTPMethod.swift
//  
//
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
    
    public static let GET: Self = "GET"
    public static let POST: Self = "POST"
    public static let PATCH: Self = "PATCH"
    public static let PUT: Self = "PUT"
    public static let DELETE: Self = "DELETE"
    public static let OPTIONS: Self = "OPTIONS"
    public static let HEAD: Self = "HEAD"
    public static let TRACE: Self = "TRACE"
}
