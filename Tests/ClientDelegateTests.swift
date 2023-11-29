//
//  ClientDelegateTests.swift
//
//
//  Created by Florian Claisse on 03/10/2023.
//

import XCTest
@testable import HTTPClient

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class ClientDelegateTests: XCTestCase {
    
    // Override query item encoding.
    func testOverridingQueryItemsEncoding() async throws {
        // GIVEN
        class ClientDelegate: HTTPClientDelegate {
            
            func client<T>(_ client: HTTPClient, makeURLForRequest request: Request<T>) throws -> URL? {
                var components = URLComponents(url: client.configuration.baseURL!.appendingPathComponent(request.url!.absoluteString), resolvingAgainstBaseURL: false)!
                
                if let query = request.query, !query.isEmpty {
                    
                    func encode(_ string: String) -> String {
                        string.addingPercentEncoding(withAllowedCharacters: .nonReservedURLQueryAllowed) ?? string
                    }

                    let percentEncoded = query.reduce(into: [String]()) { queryString, query in
                        queryString.append("\(encode(query.0))=\(encode(query.1 ?? ""))")
                    }.joined(separator: "&")

                    components.percentEncodedQuery = percentEncoded
                }
                
                guard let url = components.url else {
                    throw URLError(.badURL)
                }
                
                return url
            }
        }

        let client = HTTPClient.mock { $0.delegate = ClientDelegate() }
        let request = Request(path: "/domain.tld", query: [("query", "value1+value2")])

        // WHEN
        let urlRequest = try await client.makeURLRequest(for: request)

        // THEN "+" is percent encoded
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.github.com/domain.tld?query=value1%2Bvalue2")
    }
}

private extension CharacterSet {
     
     static let nonReservedURLQueryAllowed: CharacterSet = {
         let encodableCharacters = CharacterSet(charactersIn: ":#[]@!$&'()*+,;=")
         return CharacterSet.urlQueryAllowed.subtracting(encodableCharacters)
     }()
 }
