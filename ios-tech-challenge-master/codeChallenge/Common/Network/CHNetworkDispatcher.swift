//
//  CHNetworkDispatcher.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class CHNetworkDispatcher: NSObject {
    
    typealias Result = Challenge.Result

    private(set) var session: URLSession!
    let operationQueue: CHOperationQueue
    let dispatchQueue: DispatchQueue
    private let operations = CHWeakArray<INetworkTaskOperation>()
    private let threadLock = NSLock()

    init(queue: DispatchQueue, configuration: URLSessionConfiguration, maxConcurrentOperationCount: Int = 20) {
        self.operationQueue = CHOperationQueue(operationMaxCount: maxConcurrentOperationCount, underlyingQueue: queue)
        self.dispatchQueue = queue
        super.init()
        let operationQueue = Foundation.OperationQueue()
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
        operationQueue.underlyingQueue = queue
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
    }
    
    func generateNetworkDownloadOperation(task: URLSessionDownloadTask, callBack: @escaping CallBack<URL>, progressHandler: Progress?) -> CHNetworkDownloadOperation {
        return CHNetworkDownloadOperation(task: task, queue: self.dispatchQueue, callBack, progressHandler)
    }
    
    func run(operation: INetworkOperation) {
        self.dispatchQueue.async {
            self.threadLock.lock()
            self.operations.addObject(operation as! INetworkTaskOperation)
            if let operation = operation as? CHOperationBase {
                self.operationQueue.add(operation)
            }
            self.threadLock.unlock()
        }
    }
                    
}

extension CHNetworkDispatcher {
    
    typealias CallBack<T> = (_ result: Result<T>) -> Void
    
    private func request<Decoder: INetworkOperationDecoder>(request: URLRequest, decoder: Decoder, callBack: @escaping CallBack<Decoder.T>) -> INetworkOperation {
        let task = self.session.dataTask(with: request)
        let operation = CHNetworkDataOperation<Decoder>(task: task, decoder: decoder, queue: self.dispatchQueue, callBack)
        self.run(operation: operation)
        return operation
    }
    
    func request<Decoder: INetworkOperationDecoder>(request: IRequest, decoder: Decoder, callBack: @escaping CallBack<Decoder.T>) -> INetworkOperation? {
        do {
            let request = try request.asRequest()
            return self.request(request: request, decoder: decoder, callBack: callBack)
        } catch {
            let error = CHError.error(error: error)
            self.dispatchQueue.async {
                callBack(.failure(error))
            }
        }
        return nil
    }
    
    func request<T: Decodable>(decodable request: IRequest, decoder: IDecoder = JSONDecoder(), callBack: @escaping CallBack<T>) -> INetworkOperation? {
        let decoder = CHNetworkAnyDecodableDecoder<T>(decoder: decoder)
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
    func request(string request: IRequest, callBack: @escaping CallBack<String>) -> INetworkOperation? {
        let decoder = CHNetworkAnyStringDecoder()
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
    func request(data request: IRequest, callBack: @escaping CallBack<Data>) -> INetworkOperation? {
        let decoder = CHNetworkAnyDataDecoder()
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
    func requestJSON(request: IRequest, callBack: @escaping CallBack<Any>) -> INetworkOperation? {
        let decoder = CHNetworkAnyJSONDecoder()
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
}

extension CHNetworkDispatcher {
    
    typealias Progress = CHNetworkDownloadOperation.ProgressCallBack
            
    func download(request: URLRequest, autoRun: Bool, callBack: @escaping CallBack<URL>, progressHandler: Progress?) -> INetworkOperation {
        let task = self.session.downloadTask(with: request)
        let operation = self.generateNetworkDownloadOperation(task: task, callBack: callBack, progressHandler: progressHandler)
        if autoRun {
            self.run(operation: operation)
        }
        return operation
    }
    
    func download(request: IRequest, autoRun: Bool = true, callBack: @escaping CallBack<URL>, progressHandler: Progress?) -> INetworkOperation? {
        do {
            let request = try request.asRequest()
            return self.download(request: request, autoRun: autoRun, callBack: callBack, progressHandler: progressHandler)
        } catch {
            let error = CHError.error(error: error)
            self.dispatchQueue.async {
                callBack(.failure(error))
            }
        }
        return nil
    }
    
}

extension CHNetworkDispatcher: URLSessionDelegate {
    
    func operation(predicate: @escaping (INetworkTaskOperation) -> Bool) {
        self.dispatchQueue.async { [weak self] in
            self?.threadLock.lock()
            for operation in self?.operations.objects ?? [] {
                if predicate(operation) {
                    break
                }
            }
            self?.threadLock.unlock()
        }
    }
    
    private func getOperation(for taskIdentifier: Int, find: @escaping (_ result: INetworkTaskOperation?) -> Void) {
        self.threadLock.lock()
        let operation = self.operations.first(where: { $0.taskIdentifier == taskIdentifier })
        self.threadLock.unlock()
        find(operation)
    }
        
}

extension CHNetworkDispatcher: URLSessionTaskDelegate {
        
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.getOperation(for: task.taskIdentifier) { result in
            result?.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
    
}

extension CHNetworkDispatcher: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.getOperation(for: dataTask.taskIdentifier) { result in
            result?.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    
}

extension CHNetworkDispatcher: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.getOperation(for: downloadTask.taskIdentifier) { result in
            (result as? CHNetworkDownloadOperation)?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.getOperation(for: downloadTask.taskIdentifier) { result in
            (result as? CHNetworkDownloadOperation)?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        self.getOperation(for: downloadTask.taskIdentifier) { result in
            (result as? CHNetworkDownloadOperation)?.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        }
    }
    
}
