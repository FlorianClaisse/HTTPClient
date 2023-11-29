//
//  ClientIntegrationTests.swift
//
//
//  Created by Florian Claisse on 03/10/2023.
//

import XCTest
@testable import HTTPClient

final class HTTPClientIntegrationTests: XCTestCase {

    func _testGitHubUsersApi() async throws {
        let client = HTTPClient.mock()
        let user = try await client.send(Paths.users("FlorianClaisse").get).value
        XCTAssertEqual(user.login, "FlorianClaisse")
    }
}
