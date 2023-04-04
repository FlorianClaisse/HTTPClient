//
//  ClientIntegrationTests.swift

import XCTest
@testable import HTTPClient

final class APIClientIntegrationTests: XCTestCase {

    func _testGitHubUsersApi() async throws {
        let client = HTTPClient.mock()
        let user = try await client.send(Paths.users("FlorianClaisse").get).value
        XCTAssertEqual(user.login, "FlorianClaisse")
    }
}
