//
//  TaskHandler.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal class TaskHandler {
    
    internal let delegate: URLSessionTaskDelegate?
    internal var metrics: URLSessionTaskMetrics?
    
    init(delegate: URLSessionTaskDelegate?) {
        self.delegate = delegate
    }
}
