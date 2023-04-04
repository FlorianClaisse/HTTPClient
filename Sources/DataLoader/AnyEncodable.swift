//
//  AnyEncodable.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal struct AnyEncodable: Encodable {
    internal let value: Encodable
    
    internal func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
