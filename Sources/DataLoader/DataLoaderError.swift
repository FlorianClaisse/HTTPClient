//
//  DataLoaderError.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal struct DataLoaderError: Error {
    internal let task: URLSessionTask
    internal let error: Error
}
