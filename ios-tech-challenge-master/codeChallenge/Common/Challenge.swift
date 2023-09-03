//
//  Challenge.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class Challenge {
    
    static public let shared: Challenge = Challenge(queue: Challenge.queue)
    
    static let queue = DispatchQueue(label: "Challenge")
    private let operationManager = CHOperationManager()
    let network: CHNetworkDispatcher
    let imageService: CHImageService
    
    private init(queue: DispatchQueue) {
        self.network = .init(queue: queue, configuration: .default)
        self.operationManager.append(queue: self.network.operationQueue, queueType: .network)
        
        self.imageService = .init(queue: queue, memoryCache: CHImageService.MemoryCache(), hardwareCache: nil)
        self.operationManager.append(queue: self.imageService.operationQueue, queueType: .network)
    }
    
}

extension Challenge {
    
    enum Result<T> {
        case success(_ t: T)
        case failure(_ error: IError)
    }
    
}
