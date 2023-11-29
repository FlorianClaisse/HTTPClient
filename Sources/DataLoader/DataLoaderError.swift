//
//  DataLoaderError.swift
//  
//
//  Created by Florian Claisse on 30/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct DataLoaderError: Error {
    let task: URLSessionTask
    let error: Error
}
