//
//  Helpers.swift
//
//
//  Created by Florian Claisse on 03/10/2023.
//

import XCTest
import HTTPClient

extension HTTPClient {
    
    static func mock(_ configure: (inout HTTPClient.Configuration) -> Void = { _ in }) -> HTTPClient {
        HTTPClient(baseURL: URL(string: "https://api.github.com")) {
            $0.sessionConfiguration.protocolClasses = [MockingURLProtocol.self]
            $0.sessionConfiguration.urlCache = nil
            configure(&$0)
        }
    }
}


func json(named name: String) -> Data {
    let url = Bundle.module.url(forResource: name, withExtension: "json")
    return try! Data(contentsOf: url!)
}

extension Mock {
    
    static func get(url: URL, json name: String) -> Mock {
        Mock(url: url, dataType: .json, statusCode: 200, data: [.get: json(named: name)])
    }
}

extension InputStream {
    
    var data: Data {
        open()
        let bufferSize: Int = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()
        while hasBytesAvailable {
            let readDat = read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readDat)
        }
        buffer.deallocate()
        close()
        return data
    }
}
