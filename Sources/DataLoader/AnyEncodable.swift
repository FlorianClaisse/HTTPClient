//
//  AnyEncodable.swift
//
//
//  Created by Florian Claisse on 30/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct AnyEncodable: Encodable {
    let value: Encodable
    
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
