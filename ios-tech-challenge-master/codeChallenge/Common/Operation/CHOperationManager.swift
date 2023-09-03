//
//  OperationManager.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class CHOperationManager {
    
    private var queues: [String: CHOperationQueue] = [String: CHOperationQueue]()
    
    func append(queue: CHOperationQueue, queueType: QueueType) {
        self.queues[queueType.hashString] = queue
    }
    
    func cancelAllOperations() {
        self.queues.forEach { keyValue in
            keyValue.value.cancelAllOperations()
        }
    }
}

extension CHOperationManager {
    
    enum QueueType: Hashable {
        case network
        case imageDownload
        case coustom(id: String)
        
        var hashString: String {
            switch self {
            case .network:
                return "network"
            case .imageDownload:
                return "imageDownload"
            case .coustom(let id):
                return id
            }
        }
    }
}
