//
//  TaskHandler.swift
//
//
//  Created by Florian Claisse on 30/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal class TaskHandler {
    let delegate: URLSessionTaskDelegate?
    var metrics: URLSessionTaskMetrics?
    
    init(delegate: URLSessionTaskDelegate?) {
        self.delegate = delegate
    }
}
