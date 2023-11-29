//
//  TaskHandlersDictionary.swift
//  
//
//  Created by Florian Claisse on 30/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// With iOS 16, there is now a delegate method (`didCreateTask`) that gets
/// called outside of the session's delegate queue, which means that the access
/// needs to be synchronized.
internal final class TaskHandlersDictionary {
    private let lock = NSLock()
    private var handlers = [URLSessionTask: TaskHandler]()
    
    subscript(task: URLSessionTask) -> TaskHandler? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return handlers[task]
        } set {
            lock.lock()
            defer { lock.unlock() }
            handlers[task] = newValue
        }
    }
}
