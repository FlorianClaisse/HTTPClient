//
//  ResponseTests.swift
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

final class ResponseTests: XCTestCase {
    
    func testMapResponse() {
        // GIVEN
        let url = URL(string: "https://api.github.com/user")!
        let response = Response(
            value: "1",
            response: URLResponse(url: url, mimeType: "text", expectedContentLength: 1, textEncodingName: nil),
            data: "1".data(using: .utf8)!,
            task: URLSession.shared.dataTask(with: url)
        )

        // WHEN
        let mapped = response.map { Int($0) }

        // THEN
        XCTAssertEqual(mapped.value, 1)
    }
}
