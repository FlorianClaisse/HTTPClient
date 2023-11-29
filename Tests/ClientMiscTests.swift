//
//  ClientMiscTests.swift
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

final class ClientMiscTests: XCTestCase {
    
    /// Making sure all expected APIs compile
    func testClientInit() {
        _ = HTTPClient(baseURL: nil)
        _ = HTTPClient(baseURL: URL(string: "https://api.github.com"))
        _ = HTTPClient(baseURL: URL(string: "https://api.github.com")) {
            $0.sessionConfiguration.httpAdditionalHeaders = ["x-test": "1"]
        }
        _ = HTTPClient(configuration: .init(baseURL: URL(string: "https://api.github.com")))
    }

    func testThatActorCanImplementClientDelegate() {
        actor ClientDelegate: HTTPClientDelegate {
            
            var value = 0

            func client(_ client: HTTPClient, willSendRequest request: inout URLRequest) async throws {
                _ = value
            }

            func client(_ client: HTTPClient, shouldRetry task: URLSessionTask, error: Error, attempts: Int) async throws -> Bool {
                _ = value
                return false
            }

            nonisolated func client(_ client: HTTPClient, makeURLFor url: String, query: [(String, String?)]?) throws -> URL? {
                // _ = value – this won't compile
                return URL(string: url)
            }

            nonisolated func client(_ client: HTTPClient, validateResponse response: HTTPURLResponse, data: Data, task: URLSessionTask) throws {
                // _ = value – this won't compile
            }
        }
    }
}
