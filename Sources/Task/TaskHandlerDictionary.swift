//
//  TaskHandlerDictionary.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// With iOS 16, there is now a delegate method (`didCreateTask`) that gets
/// called outside of the session's delegate queue, which means that the access
/// needs to be synchronized.
internal final class TaskHandlerDictionary {
    
    private let lock = NSLock()
    private var handlers = [URLSessionTask: TaskHandler]()
    
    subscript(task: URLSessionTask) -> TaskHandler? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return handlers[task]
        } set(newValue) {
            lock.lock()
            defer { lock.unlock() }
            handlers[task] = newValue
        }
    }
}
