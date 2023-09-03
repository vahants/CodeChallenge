//
//  CHNetworkDownloadOperation.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 27.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class CHNetworkDownloadOperation: CHNetworkOperation<URL, URLSessionDownloadTask> {
    
    typealias ProgressCallBack = CallBack<Progress>
    
    private var progressHandler: ProgressCallBack?
    
    init(task: URLSessionDownloadTask, queue: DispatchQueue, _ callBack: @escaping CallBack<Challenge.Result<URL>>, _ progressHandler: ProgressCallBack?) {
        self.progressHandler = progressHandler
        super.init(task: task, queue: queue, callBack)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.response(value: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progressHandler?(downloadTask.progress)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {}
}
