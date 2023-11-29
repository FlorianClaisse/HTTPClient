//
//  CodeSamplesTests.swift
//
//
//  Created by Florian Claisse on 03/10/2023.
//

import XCTest
import HTTPClient

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

func checkSample01() {
    final class ClientDelegate: HTTPClientDelegate {
        private var accessToken: String = ""

        func client(_ client: HTTPClient, willSendRequest request: inout URLRequest) async throws {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        func client(_ client: HTTPClient, shouldRetry task: URLSessionTask, error: Error, attempts: Int) async throws -> Bool {
            if case .unacceptableStatusCode(let statusCode) = error as? HTTPClientError, statusCode == 401, attempts == 1 {
                accessToken = try await refreshAccessToken()
                return true
            }
            return false
        }

        private func refreshAccessToken() async throws -> String {
            fatalError("Not implemented")
        }
    }
}
