//
//  Functions.swift
//  
//
//  Created by Florian Claisse on 30/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

func encode(_ value: Encodable, using encoder: JSONEncoder) async throws -> Data? {
    if let data = value as? Data {
        return data
    } else if let string = value as? String {
        return string.data(using: .utf8)
    } else {
        return try await Task.detached {
            try encoder.encode(AnyEncodable(value: value))
        }.value
    }
}

func decode<T: Decodable>(_ data: Data, using decoder: JSONDecoder) async throws -> T {
    if data.isEmpty, T.self is OptionalDecoding.Type {
        return Optional<Decodable>.none as! T
    } else if T.self == Data.self {
        return data as! T
    } else if T.self == String.self {
        guard let string = String(data: data, encoding: .utf8) else {
            throw URLError(.badServerResponse)
        }
        return string as! T
    } else {
        return try await Task.detached {
            try decoder.decode(T.self, from: data)
        }.value
    }
}
