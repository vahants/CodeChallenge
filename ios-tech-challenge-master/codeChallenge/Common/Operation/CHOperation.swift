//
//  CHOperation.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class CHOperation<T>: CHOperationBase {
    
    private var responseHandler: CallBack<Result<T>>?
    
    init(_ responseHandler: @escaping CallBack<Result<T>>) {
        self.responseHandler = responseHandler
    }
    
    func response(_ result: Result<T>) {
        self.underlyingQueue { [weak self] in
            self?.responseHandler?(result)
            self?.responseHandler = nil
            self?.finish()
        }
    }
    
    func response(value: T) {
        let result = Result.success(value)
        self.response(result)
    }
    
    func response(error: IError) {
        let result = Result<T>.failure(error)
        self.response(result)
    }
    
    override func cancel() {
        super.cancel()
        self.response(error: CHError.canceled)
    }
            
}

extension CHOperation {
    typealias CallBack<T> = (_ result: T) -> Void
    typealias Result = Challenge.Result
}

