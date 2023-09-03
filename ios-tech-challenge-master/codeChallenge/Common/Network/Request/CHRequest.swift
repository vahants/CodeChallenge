//
//  IRequest.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

protocol IRequest {
    func asRequest() throws -> URLRequest
}

class CHRequest: IRequest {
    
    let url: URL
    let method: HTTPMethod?
    let body: [String: Any?]?
    let headers: [String: String?]?
    let queryParams: [String: String?]?
    let timeoutInterval: TimeInterval
    
    convenience init(urlStr: String, method: HTTPMethod? = nil, params: [String : Any?]? = nil, headers: [String : String?]? = nil, queryParams: [String : String?]? = nil, timeoutInterval: TimeInterval = 60.0) throws {
        guard let url = URL(string: urlStr) else {
            throw CHRequest.RequestError.requestNotValid(url: urlStr)
        }
        self.init(url: url, method: method, params: params, headers: headers, queryParams: queryParams, timeoutInterval: timeoutInterval)
    }
    
    init(url: URL, method: HTTPMethod? = nil, params: [String : Any?]? = nil, headers: [String : String?]? = nil, queryParams: [String : String?]? = nil, timeoutInterval: TimeInterval = 60.0) {
        self.url = url
        self.method = method
        self.body = params
        self.headers = headers
        self.queryParams = queryParams
        self.timeoutInterval = timeoutInterval
    }
    
    func asRequest() throws -> URLRequest {
        
        guard var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false) else {
            throw RequestError.requestNotValid(url: self.url.absoluteString)
        }
                    
        let queryItems = self.queryParams?.compactMap({ keyValue in
            return URLQueryItem(name: keyValue.key, value: keyValue.value)
        })
        
        var existedQuery = components.queryItems ?? []
        
        if let queryItems = queryItems {
            existedQuery.append(contentsOf: queryItems)
        }
        
        components.queryItems = existedQuery
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let url = components.url else {
            throw RequestError.requestNotValid(url: self.url.absoluteString)
        }
        var request = URLRequest(url: url, timeoutInterval: self.timeoutInterval)
        request.httpMethod = self.method?.httpMethod
        
        self.headers?.forEach({ keyValue in
            request.setValue(keyValue.value, forHTTPHeaderField: keyValue.key)
        })
        
        if let body = self.body {
            do {
                let data = try JSONSerialization.data(withJSONObject: body)
                request.httpBody = data
            } catch {
                throw CHError.error(error: error)
            }
        }
        return request
    }
    
}


extension CHRequest {
    
    enum RequestError: IError {
        
        case requestNotValid(url: String)
        
        var code: Int? {
            switch self {
            case .requestNotValid:
                return -10
            }
        }
        
        var message: String? {
            switch self {
            case .requestNotValid(let url):
                return "request not valid \(url)"
            }
        }
    }
    
    public enum HTTPMethod {
        
        case get
        case post
        case put
        case patch
        case delete
        case custom(method: String)
        
        var httpMethod: String {
            switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .patch:
                return "PATCH"
            case .delete:
                return "DELETE"
            case .custom(let method):
                return method
            }
        }
    }
    
}

extension CHRequest {
    
    convenience init(image flickrPhoto: CHFlickrPhoto, size: CHFlickrPhoto.PhotoSize) throws {
        guard let server = flickrPhoto.server, let secret = flickrPhoto.secret else {
            throw CHError.incorrectUrl
        }
        let urlStr = "https://live.staticflickr.com/\(server)/\(flickrPhoto.id)_\(secret)_\(size.suffix).jpg"
        try self.init(urlStr: urlStr)
    }
    
}
