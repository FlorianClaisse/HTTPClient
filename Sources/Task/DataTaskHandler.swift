//
//  DataTaskHandler.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal final class DataTaskHandler: TaskHandler {
    typealias Completion = (Result<Response<Data>, Error>) -> Void
    
    internal let dataDelegate: URLSessionDataDelegate?
    internal var completion: Completion?
    internal var data: Data?
    
    override init(delegate: URLSessionTaskDelegate?) {
        self.dataDelegate = delegate as? URLSessionDataDelegate
        super.init(delegate: delegate)
    }
}
