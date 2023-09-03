//
//  CHImageService.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 27.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

protocol IImageServiceCache: AnyObject {
    func read(identifier: String) throws -> Data
    func write(identifier: String, image: Data) throws
}

class CHImageService: CHNetworkDispatcher {
    
    let hardwareCache: IImageServiceCache?
    let memoryCache: IImageServiceCache
    private let threadLock = CHLocker()
    
    private var operations = [URL: CHImageServiceOperation]()
    
    init(queue: DispatchQueue, maxConcurrentOperationCount: Int = 20, memoryCache: IImageServiceCache, hardwareCache: IImageServiceCache?) {
        self.memoryCache = memoryCache
        self.hardwareCache = hardwareCache
        super.init(queue: queue, configuration: .default, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }
    
    override func generateNetworkDownloadOperation(task: URLSessionDownloadTask, callBack: @escaping CHNetworkDispatcher.CallBack<URL>, progressHandler: CHNetworkDispatcher.Progress?) -> CHNetworkDownloadOperation {
        return CHImageServiceOperation(task: task, queue: self.dispatchQueue, hardwareCache: self.hardwareCache, memoryCache: self.memoryCache, callBack: { [weak self] result in
            self?.removeOperation(task)
            callBack(result)
        }, progressHandler)
    }
    
    @discardableResult
    func downloadImage(request: URLRequest, imageHandler: @escaping CHImageServiceOperation.CallBack<Result<UIImage>>, progress: CHNetworkDispatcher.Progress? = nil) -> CHImageServiceOperation.Token? {
       
        if let operation = self.getOperation(for: request), operation.isExecuting {
            return operation.createToken(imageHandler: imageHandler, progress: progress)
        } else {
            let networkOperation = self.download(request: request, autoRun: false) { result in
                
            } progressHandler: { result in }
            
            let token = (networkOperation as? CHImageServiceOperation)?.createToken(imageHandler: imageHandler, progress: progress)
            self.addOperation(operation: networkOperation as! CHImageServiceOperation)
            self.run(operation: networkOperation)
            return token
        }
    }
    
    @discardableResult
    func downloadImage(request: IRequest, imageHandler: @escaping CHImageServiceOperation.CallBack<Result<UIImage>>, progress: CHNetworkDispatcher.Progress? = nil) -> CHImageServiceOperation.Token? {
        do {
            let request = try request.asRequest()
            return self.downloadImage(request: request, imageHandler: imageHandler, progress: progress)
        } catch {
            imageHandler(.failure(CHError.error(error: error)))
            return nil
        }
    }
    
    private func getOperation(for request: URLRequest) -> CHImageServiceOperation? {
        return self.threadLock.locked { [weak self] in
            guard let url = request.url else {
                return nil
            }
            return self?.operations[url]
        }
    }
    
    private func addOperation(operation: CHImageServiceOperation) {
        self.threadLock.locked { [weak self] in
            guard let url = operation.sessionTask.originalRequest?.url else {
                return
            }
            self?.operations[url] = operation
        }
    }
    
    private func removeOperation(for request: URLRequest) {
        self.threadLock.locked { [weak self] in
            guard let url = request.url else {
                return
            }
            self?.operations[url] = nil
        }
    }
    
    private func removeOperation(_ operation: CHImageServiceOperation) {
        self.threadLock.locked { [weak self] in
            guard let url = operation.sessionTask.originalRequest?.url else {
                return
            }
            self?.operations[url] = nil
        }
    }
    
    private func removeOperation(_ sessionTask: URLSessionTask) {
        self.threadLock.locked { [weak self] in
            guard let url = sessionTask.originalRequest?.url else {
                return
            }
            self?.operations[url] = nil
        }
    }
    
}

extension CHImageService {
    typealias Token = CHImageServiceOperation.Token
}

extension CHImageService {
    
    class MemoryCache: IImageServiceCache {
        
        private let cache: NSCache<NSString, NSData>
        
        init() {
            self.cache = NSCache()
            self.cache.countLimit = 330
        }
        
        func read(identifier: String) throws -> Data {
            guard let data = self.cache.object(forKey: identifier as NSString) else {
                throw CHError.notFound
            }
            return data as Data
        }
        
        func write(identifier: String, image: Data) throws {
            self.cache.setObject(image as NSData, forKey: identifier as NSString)
        }
    }
    
}
