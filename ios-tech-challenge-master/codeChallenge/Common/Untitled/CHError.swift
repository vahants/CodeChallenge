//
//  CHError.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

public protocol IError: Error {
    var code: Int? { get }
    var message: String? { get }
    var isCanceled: Bool { get }
}

extension IError {
    
    var isCanceled: Bool {
        return false
    }
    
}

enum CHError: IError {
            
    case error(error: Error)
    case canceled
    case incorrectUrl
    case notFound
    case incorrectParsing(message: String, code: Int)
    
    var code: Int? {
        switch self {
        case .error(let error):
            if let error = error as? IError {
                return error.code
            }
            return (error as NSError).code
        case .canceled:
            return -999
        case .incorrectUrl:
            return -100
        case .incorrectParsing(_, let code):
            return code
        case .notFound:
            return 404
        }
    }
    
    var message: String? {
        switch self {
        case .error(let error):
            if let error = error as? IError {
                return error.message
            }
            return (error as NSError).localizedDescription
        case .canceled:
            return "Request is canceled"
        case .incorrectUrl:
            return "Incorrect Url"
        case .incorrectParsing(let message, _):
            return message
        case .notFound:
            return "Not Found"
        }
    }
    
    var isCanceled: Bool {
        switch self {
        case .error(let error):
            return (error as NSError).code == -999
        case .canceled:
            return true
        case .incorrectUrl, .incorrectParsing, .notFound:
            return false
        }
    }
    
}
