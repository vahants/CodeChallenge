//
//  CHNetworkOperation.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

@objc protocol INetworkOperation: IOperation {
    var sessionTask: URLSessionTask { get }
}

extension INetworkOperation {
    
    var taskIdentifier: Int {
        return self.sessionTask.taskIdentifier
    }
    
}

protocol INetworkTaskOperation: INetworkOperation {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
}

class CHNetworkOperation<T, Task: URLSessionTask>: CHOperation<T>, INetworkTaskOperation {
        
    private let task: Task
    
    var sessionTask: URLSessionTask {
        return self.task
    }
            
    init(task: Task, queue: DispatchQueue, _ responseHandler: @escaping CallBack<Result<T>>) {
        self.task = task
        super.init(responseHandler)
    }
    
    override func resume() {
        super.resume()
        self.resumeTask()
    }
    
    override func cancel() {
        super.cancel()
        self.task.cancel()
    }
    
    func resumeTask() {
        self.task.resume()
    }
        
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {}
    
}
