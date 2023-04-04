//
//  DataLoader.swift
//  
//
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal final class DataLoader: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate, @unchecked Sendable {
    
    private let handlers = TaskHandlerDictionary()
    
    private var userTaskDelegate: URLSessionTaskDelegate?
    private var userDataDelegate: URLSessionDataDelegate?
    private var userDownloadDelegate: URLSessionDownloadDelegate?
    
    internal var userSessionDelegate: URLSessionDelegate? {
        didSet {
            userTaskDelegate = userSessionDelegate as? URLSessionTaskDelegate
            userDataDelegate = userSessionDelegate as? URLSessionDataDelegate
            userDownloadDelegate = userSessionDelegate as? URLSessionDownloadDelegate
        }
    }
    
    private static let downloadDirectoryURL: URL = {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("com.github.FlorianClaisse.HTTPClient/Downloads/")
        try? FileManager.default.removeItem(at: url)
        return url
    }()
    
    internal func startDataTask(_ task: URLSessionDataTask, session: URLSession, delegate: URLSessionDataDelegate?) async throws -> Response<Data> {
        try await withTaskCancellationHandler(operation: {
            try await withUnsafeThrowingContinuation { continuation in
                let handler = DataTaskHandler(delegate: delegate)
                handler.completion = continuation.resume(with:)
                self.handlers[task] = handler
                
                task.resume()
            }
        }, onCancel: {
            task.cancel()
        })
    }
    
    internal func startDownloadTask(_ task: URLSessionDownloadTask, session: URLSession, delegate: URLSessionDownloadDelegate?) async throws -> Response<URL> {
        try await withTaskCancellationHandler(operation: {
            try await withUnsafeThrowingContinuation { continuation in
                let handler = DownloadTaskHandler(delegate: delegate)
                handler.completion = continuation.resume(with:)
                self.handlers[task] = handler
                
                task.resume()
            }
        }, onCancel: {
            task.cancel()
        })
    }
    
    internal func startUploadTask(_ task: URLSessionUploadTask, session: URLSession, delegate: URLSessionTaskDelegate?) async throws -> Response<Data> {
        try await withTaskCancellationHandler(operation: {
            try await withUnsafeThrowingContinuation { continuation in
                let handler = DataTaskHandler(delegate: delegate)
                handler.completion = continuation.resume(with:)
                self.handlers[task] = handler
                
                task.resume()
            }
        }, onCancel: {
            task.cancel()
        })
    }
    
    // MARK: - URLSessionDelegate
    
    internal func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
#if os(Linux)
        userSessionDelegate?.urlSession(session, didBecomeInvalidWithError: error)
#else
        userSessionDelegate?.urlSession?(session, didBecomeInvalidWithError: error)
#endif
    }
    
#if !os(Linux)
    internal func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if #available(macOS 11.0, *) {
            userSessionDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        } else {
            // Fallback on earlier versions
        }
    }
#endif
    
    // MARK: - URLSessionTaskDelegate
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let handler = handlers[task] else { return assertionFailure() }
        handlers[task] = nil
#if os(Linux)
        handler.delegate?.urlSession(session, task: task, didCompleteWithError: error)
        userTaskDelegate?.urlSession(session, task: task, didCompleteWithError: error)
#else
        handler.delegate?.urlSession?(session, task: task, didCompleteWithError: error)
        userTaskDelegate?.urlSession?(session, task: task, didCompleteWithError: error)
#endif
        switch handler {
        case let handler as DataTaskHandler:
            if let response = task.response, error == nil {
                let data = handler.data ?? Data()
                let response = Response(value: data, data: data, response: response, task: task, metrics: handler.metrics)
                handler.completion?(.success(response))
            } else {
                handler.completion?(.failure(error ?? URLError(.unknown)))
            }
        case let handler as DownloadTaskHandler:
            if let location = handler.location, let response = task.response, error == nil {
                let response = Response(value: location, data: Data(), response: response, task: task, metrics: handler.metrics)
                handler.completion?(.success(response))
            } else {
                handler.completion?(.failure(error ?? URLError(.unknown)))
            }
        default:
            break
        }
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        let handler = handlers[task]
        handler?.metrics = metrics
#if os(Linux)
        handler?.delegate?.urlSession(session, task: task, didFinishCollecting: metrics)
        userTaskDelegate?.urlSession(session, task: task, didFinishCollecting: metrics)
#else
        handler?.delegate?.urlSession?(session, task: task, didFinishCollecting: metrics)
        userTaskDelegate?.urlSession?(session, task: task, didFinishCollecting: metrics)
#endif
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
#if os(Linux)
        handlers[task]?.delegate?.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler) ??
        userTaskDelegate?.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler) ??
        completionHandler(request)
#else
        handlers[task]?.delegate?.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler) ??
        userTaskDelegate?.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler) ??
        completionHandler(request)
#endif
    }
    
#if !os(Linux)
    internal func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        handlers[task]?.delegate?.urlSession?(session, taskIsWaitingForConnectivity: task)
        userTaskDelegate?.urlSession?(session, taskIsWaitingForConnectivity: task)
    }
    
#if !os(macOS) && !targetEnvironment(macCatalyst) && swift(>=5.7)
    internal func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            handlers[task]?.delegate?.urlSession?(session, didCreateTask: task)
            userTaskDelegate?.urlSession?(session, didCreateTask: task)
        } else {
            // Doesn't exist on earlier versions
        }
    }
#endif
#endif
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
#if os(Linux)
        handlers[task]?.delegate?.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler) ??
        userTaskDelegate?.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler) ??
        completionHandler(.performDefaultHandling, nil)
#else
        handlers[task]?.delegate?.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler) ??
        userTaskDelegate?.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler) ??
        completionHandler(.performDefaultHandling, nil)
#endif
    }
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
#if os(Linux)
        handlers[task]?.delegate?.urlSession(session, task: task, willBeginDelayedRequest: request, completionHandler: completionHandler) ??
        userTaskDelegate?.urlSession(session, task: task, willBeginDelayedRequest: request, completionHandler: completionHandler) ??
        completionHandler(.continueLoading, nil)
#else
        handlers[task]?.delegate?.urlSession?(session, task: task, willBeginDelayedRequest: request, completionHandler: completionHandler) ??
        userTaskDelegate?.urlSession?(session, task: task, willBeginDelayedRequest: request, completionHandler: completionHandler) ??
        completionHandler(.continueLoading, nil)
#endif
    }
    
    // MARK: - URLSessionDataDelegate
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
#if os(Linux)
        (handlers[dataTask] as? DataTaskHandler)?.dataDelegate?.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler) ??
        userDataDelegate?.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler) ??
        completionHandler(.allow)
#else
        (handlers[dataTask] as? DataTaskHandler)?.dataDelegate?.urlSession?(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler) ??
        userDataDelegate?.urlSession?(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler) ??
        completionHandler(.allow)
#endif
    }
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let handler = handlers[dataTask] as? DataTaskHandler else { return }
#if os(Linux)
        handler.dataDelegate?.urlSession(session, dataTask: dataTask, didReceive: data)
        userDataDelegate?.urlSession(session, dataTask: dataTask, didReceive: data)
#else
        handler.dataDelegate?.urlSession?(session, dataTask: dataTask, didReceive: data)
        userDataDelegate?.urlSession?(session, dataTask: dataTask, didReceive: data)
#endif
        if handler.data == nil {
            handler.data = Data()
        }
        handler.data!.append(data)
    }
    
#if !os(Linux)
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        (handlers[dataTask] as? DataTaskHandler)?.dataDelegate?.urlSession?(session, dataTask: dataTask, didBecome: downloadTask)
        userDataDelegate?.urlSession?(session, dataTask: dataTask, didBecome: downloadTask)
    }
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        (handlers[dataTask] as? DataTaskHandler)?.dataDelegate?.urlSession?(session, dataTask: dataTask, didBecome: streamTask)
        userDataDelegate?.urlSession?(session, dataTask: dataTask, didBecome: streamTask)
    }
#endif
    
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
#if os(Linux)
        (handlers[dataTask] as? DataTaskHandler)?.dataDelegate?.urlSession(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler) ??
        userDataDelegate?.urlSession(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler)
        completionHandler(proposedResponse)
#else
        (handlers[dataTask] as? DataTaskHandler)?.dataDelegate?.urlSession?(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler) ??
        userDataDelegate?.urlSession?(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler) ??
        completionHandler(proposedResponse)
#endif
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let handler = (handlers[downloadTask] as? DownloadTaskHandler)
        let downloadsURL = DataLoader.downloadDirectoryURL
        try? FileManager.default.createDirectory(at: downloadsURL, withIntermediateDirectories: true, attributes: nil)
        let newLocation = downloadsURL.appendingPathComponent(location.lastPathComponent)
        try? FileManager.default.moveItem(at: location, to: newLocation)
        handler?.location = newLocation
        handler?.downloadDelegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: newLocation)
        userDownloadDelegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: newLocation)
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
#if os(Linux)
        (handlers[downloadTask] as? DownloadTaskHandler)?.downloadDelegate?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        userDownloadDelegate?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
#else
        (handlers[downloadTask] as? DownloadTaskHandler)?.downloadDelegate?.urlSession?(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        userDownloadDelegate?.urlSession?(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
#endif
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
#if os(Linux)
        (handlers[downloadTask] as? DownloadTaskHandler)?.downloadDelegate?.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        userDownloadDelegate?.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
#else
        (handlers[downloadTask] as? DownloadTaskHandler)?.downloadDelegate?.urlSession?(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        userDownloadDelegate?.urlSession?(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
#endif
    }
}


internal func encode(_ value: Encodable, using encoder: JSONEncoder) async throws -> Data? {
    if let data = value as? Data {
        return data
    } else if let string = value as? String {
        return string.data(using: .utf8)
    } else {
        return try await Task.detached(operation: {
            try encoder.encode(AnyEncodable(value: value))
        }).value
    }
}

internal func decode<T: Decodable>(_ data: Data, using decoder: JSONDecoder) async throws -> T {
    if data.isEmpty, T.self is OptionalDecoding.Type {
        return Optional<Decodable>.none as! T
    } else if T.self == Data.self {
        return data as! T
    } else if T.self == String.self {
        guard let string = String(data: data, encoding: .utf8) else {
            throw URLError(.badServerResponse)
        }
        return string as! T
    } else {
        return try await Task.detached(operation: {
            try decoder.decode(T.self, from: data)
        }).value
    }
}
