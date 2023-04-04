//
//  DownloadTaskHandler.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal final class DownloadTaskHandler: TaskHandler {
    typealias Completion = (Result<Response<URL>, Error>) -> Void
    
    internal let downloadDelegate: URLSessionDownloadDelegate?
    internal var completion: Completion?
    internal var location: URL?
    
    init(delegate: URLSessionDownloadDelegate?) {
        self.downloadDelegate = delegate
        super.init(delegate: delegate)
    }
}
