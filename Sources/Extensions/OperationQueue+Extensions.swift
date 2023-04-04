//
//  OperationQueue+Extensions.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


extension OperationQueue {
    internal static func serial() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}
