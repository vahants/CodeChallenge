//
//  OperationQueue.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class CHOperationQueue {
    
    private let queue: OperationQueue
    
    init(operationMaxCount: Int, underlyingQueue: DispatchQueue?, qualityService: QualityOfService = .userInitiated) {
        self.queue = OperationQueue()
        self.queue.maxConcurrentOperationCount = operationMaxCount
        self.queue.qualityOfService = qualityService
        self.queue.underlyingQueue = underlyingQueue
    }
    
    init(queue: OperationQueue) {
        self.queue = queue
    }
    
    func add(_ operation: CHOperationBase) {
        operation.underlyingQueue = self.queue.underlyingQueue
        self.queue.addOperation(operation)
    }
    
    func cancelAllOperations() {
        self.queue.cancelAllOperations()
    }
    
    func allOperations() -> [CHOperationBase] {
        return self.queue.operations as? [CHOperationBase] ?? []
    }
}
