//
//  DownloadTaskHandler.swift
//
//
//  Created by Florian Claisse on 30/09/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal final class DownloadTaskHandler: TaskHandler {
    typealias Completion = (Result<Response<URL>, Error>) -> Void
    
    let downloadDelegate: URLSessionDownloadDelegate?
    var completion: Completion?
    var location: URL?
    
    init(delegate: URLSessionDownloadDelegate?) {
        self.downloadDelegate = delegate
        super.init(delegate: delegate)
    }
}
