//
//  DataTaskHandler.swift
//  
//
//  Created by Florian Claisse on 30/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal final class DataTaskHandler: TaskHandler {
    typealias Completion = (Result<Response<Data>, Error>) -> Void
    
    let dataDelegate: URLSessionDataDelegate?
    var completion: Completion?
    var data: Data?
    
    override init(delegate: URLSessionTaskDelegate?) {
        self.dataDelegate = delegate as? URLSessionDataDelegate
        super.init(delegate: delegate)
    }
}
