//
//  GitHubAPI.swift
//
//
//  Created by Florian Claisse on 03/10/2023.
//

import HTTPClient

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


// An example of an API definition. Feel free to use any other method for
// organizing the resources.
public enum Paths { }

// MARK: - /user

extension Paths {
    
    public static var user: UserResource { UserResource() }

    public struct UserResource {
        public let path: String = "/user"

        public var get: Request<User> { .init(path: path) }
    }
}

// MARK: - /user/emails

extension Paths.UserResource {
    
    public var emails: EmailsResource { EmailsResource() }

    public struct EmailsResource {
        public let path: String = "/user/emails"

        public var get: Request<[UserEmail]> { .init(path: path) }

        public func post(_ emails: [String]) -> Request<Void> {
            .init(path: path, method: .post, body: emails)
        }

        public func delete() -> Request<Void> {
            .init(path: path, method: .delete)
        }
    }
}

// MARK: - /users/{username}

extension Paths {
    
    public static func users(_ name: String) -> UsersResource {
        UsersResource(path: "/users/\(name)")
    }

    public struct UsersResource {
        public let path: String

        public var get: Request<User> { .init(path: path) }
    }
}

// MARK: - /users/{username}/followers

extension Paths.UsersResource {
    
    public var followers: FollowersResource { FollowersResource(path: path + "/followers") }

    public struct FollowersResource {
        public let path: String

        public var get: Request<[User]> { .init(path: path) }
    }
}

// MARK: - Entities

public struct UserEmail: Decodable {
    public var email: String
    public var verified: Bool
    public var primary: Bool
    public var visibility: String?
}

public struct User: Codable {
    public var id: Int
    public var login: String
    public var name: String?
    public var hireable: Bool?
    public var location: String?
    public var bio: String?
}

// MARK: - HTTPClientDelegate

enum GitHubError: Error {
    case unacceptableStatusCode(Int)
}

private final class GitHubHTTPClientDelegate: HTTPClientDelegate {
    func client(_ client: HTTPClient, willSendRequest request: inout URLRequest) async throws {
        request.setValue("Bearer \("your-access-token")", forHTTPHeaderField: "Authorization")
    }

    func shouldClientRetry(_ client: HTTPClient, for request: URLRequest, withError error: Error) async throws -> Bool {
        if case .unacceptableStatusCode(let status) = (error as? GitHubError), status == 401 {
            return await refreshAccessToken()
        }
        return false
    }

    private func refreshAccessToken() async -> Bool {
        return false
    }

    func client(_ client: HTTPClient, validateResponse response: HTTPURLResponse, data: Data, task: URLSessionTask) throws {
        guard (200 ..< 300).contains(response.statusCode) else {
            throw GitHubError.unacceptableStatusCode(response.statusCode)
        }
    }
}

// MARK: - Usage

func usage() async throws {
    let client = HTTPClient(baseURL: URL(string: "https://api.github.com")) {
        $0.delegate = GitHubHTTPClientDelegate()
    }

    _ = try await client.send(Paths.user.get)
    _ = try await client.send(Paths.user.emails.get)
    _ = try await client.send(Paths.users("FlorianClaisse").followers.get)
}
