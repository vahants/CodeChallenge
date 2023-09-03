//
//  CHImageServiceOperation.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 27.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

class CHImageServiceOperation: CHNetworkDownloadOperation {
    
    let hardwareCache: IImageServiceCache?
    let memoryCache: IImageServiceCache
    private let imageIdentifier: String?
    
    private var tokens: Set<Token> = Set<Token>()
    
    init(task: URLSessionDownloadTask, queue: DispatchQueue, hardwareCache: IImageServiceCache?, memoryCache: IImageServiceCache, callBack: @escaping CallBack<Challenge.Result<URL>>, _ progressHandler: ProgressCallBack?) {
        self.hardwareCache = hardwareCache
        self.memoryCache = memoryCache
        self.imageIdentifier = task.originalRequest?.url?.absoluteString
        super.init(task: task, queue: queue, callBack, progressHandler)
    }
    
    override func response(error: IError) {
        self.tokens.forEach { token in
            DispatchQueue.main.async {
                token.imageHandler(.failure(error))
            }
        }
        super.response(error: error)
    }
    
    override func resumeTask() {
        guard self.imageIdentifier != nil else {
            self.response(error: CHError.incorrectUrl)
            return
        }
        
        if let image = self.getImageFromMemoryCache() {
            self.tokens.forEach { token in
                DispatchQueue.main.async {
                    token.imageHandler(.success(image))
                }
            }
            super.response(.success(URL(fileURLWithPath: "")))
        } else if let image = self.getImageFromHardwareCache() {
            self.tokens.forEach { token in
                DispatchQueue.main.async {
                    token.imageHandler(.success(image.image))
                }
            }
        } else {
            super.resumeTask()
        }
                        
    }
    
    override func response(_ result: Challenge.Result<URL>) {
        
        guard let imageIdentifier = self.imageIdentifier else {
            self.response(error: CHError.incorrectUrl)
            return
        }
        
        if !self.isCancelled {
            switch result {
            case .success(let url):
                do {
                    let data = try Data(contentsOf: url)
                    try self.hardwareCache?.write(identifier: imageIdentifier, image: data)
                    try self.memoryCache.write(identifier: imageIdentifier, image: data)
                    let imageData = try self.memoryCache.read(identifier: imageIdentifier)
                    guard let image = UIImage(data: imageData) else {
                        super.response(.failure(CHError.incorrectUrl))
                        self.tokens.forEach { token in
                            DispatchQueue.main.async {
                                token.imageHandler(.failure(CHError.incorrectUrl))
                            }
                        }
                        return
                    }
                    
                    self.tokens.forEach { token in
                        DispatchQueue.main.async {
                            token.imageHandler(.success(image))
                        }
                    }
                } catch {
                    super.response(.failure(CHError.error(error: error)))
                    self.tokens.forEach { token in
                        DispatchQueue.main.async {
                            token.imageHandler(.failure(CHError.error(error: error)))
                        }
                    }
                    return
                }
            default:
                break
            }
        }
        super.response(result)
    }
    
    func createToken(imageHandler: @escaping CallBack<Result<UIImage>>, progress: ProgressCallBack?) -> Token {
        let token = Token(imageHandler: imageHandler, progress: progress) { [weak self] token in
            self?.underlyingQueue {
                self?.tokens.remove(token)
                if (self?.tokens.isEmpty ?? true) {
                    self?.cancel()
                }
            }
        }
        
        self.underlyingQueue { [weak self] in
            self?.tokens.insert(token)
        }
        
        return token
    }
    
    private func getImageFromMemoryCache() -> UIImage? {
        guard let imageIdentifier = self.imageIdentifier, let imageData = try? self.memoryCache.read(identifier: imageIdentifier), let image = UIImage(data: imageData) else {
            return nil
        }
        return image
    }
    
    private func getImageFromHardwareCache() -> (image: UIImage, data: Data, identifier: String)? {
        guard let imageIdentifier = self.imageIdentifier, let imageData = try? self.hardwareCache?.read(identifier: imageIdentifier), let image = UIImage(data: imageData) else {
            return nil
        }
        return (image: image, data: imageData, imageIdentifier)
    }
    
}

extension CHImageServiceOperation {
    
    final class Token: Equatable, Hashable {
                
        fileprivate let identifier: String = UUID().uuidString
        fileprivate let imageHandler: CallBack<Result<UIImage>>
        fileprivate let progress: ProgressCallBack?
        private let cancellToken: ((_ token: Token) -> Void)?
        
        init(imageHandler: @escaping CallBack<Result<UIImage>>, progress: ProgressCallBack?, cancellToken: ((_ token: Token) -> Void)?) {
            self.imageHandler = imageHandler
            self.progress = progress
            self.cancellToken = cancellToken
        }
        
        func cancell() {
            self.cancellToken?(self)
        }
        
        static func == (lhs: CHImageServiceOperation.Token, rhs: CHImageServiceOperation.Token) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
        
    }
        
}
