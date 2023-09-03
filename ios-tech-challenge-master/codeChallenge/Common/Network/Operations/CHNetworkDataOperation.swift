//
//  CHNetworkDataOperation.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class CHNetworkDataOperation<Decoder: INetworkOperationDecoder>: CHNetworkOperation<Decoder.T, URLSessionDataTask> {
    
    typealias T = Decoder.T
    
    let decoder: Decoder
    private var data = Data()
    
    init(task: URLSessionDataTask, decoder: Decoder, queue: DispatchQueue, _ responseHandler: @escaping CallBack<Challenge.Result<T>>) {
        self.decoder = decoder
        super.init(task: task, queue: queue, responseHandler)
    }
            
    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        super.urlSession(session, task: task, didCompleteWithError: error)
        if let error = error {
            self.response(error: CHError.error(error: error))
        } else {
            self.response(data: self.data)
        }
    }
    
    override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        super.urlSession(session, dataTask: dataTask, didReceive: data)
        self.data.append(data)
    }
    
    func response(data: Data) {
        do {
            let result = try self.decoder.decode(T.self, from: data)
            self.response(value: result)
        } catch {
            let error = CHError.error(error: error)
            self.response(error: error)
        }
    }
    
}
