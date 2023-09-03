//
//  DMDecoder.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

protocol IDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: IDecoder {}

protocol INetworkOperationDecoder {
    associatedtype T
    func decode(_ type: T.Type, from data: Data) throws -> T
}

struct CHNetworkAnyDecodableDecoder<Obj: Decodable>: INetworkOperationDecoder {
    
    typealias T = Obj
    
    let decoder: IDecoder
    
    init(decoder: IDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    func decode(_ type: Obj.Type, from data: Data) throws -> Obj {
        do {
            return try self.decoder.decode(type, from: data)
        } catch {
            throw CHError.error(error: error)
        }
    }
}

struct CHNetworkAnyJSONDecoder: INetworkOperationDecoder {
            
    typealias T = Any
    
    let readingOptions: JSONSerialization.ReadingOptions
    
    init(readingOptions: JSONSerialization.ReadingOptions = []) {
        self.readingOptions = readingOptions
    }
    
    func decode(_ type: T.Protocol, from data: Data) throws -> T {
        do {
            return try JSONSerialization.jsonObject(with: data, options: self.readingOptions)
        } catch {
            throw CHError.error(error: error)
        }
    }

}

struct CHNetworkAnyStringDecoder: INetworkOperationDecoder {
    
    typealias T = String
    
    func decode(_ type: String.Type, from data: Data) throws -> String {
        let str = String(decoding: data, as: UTF8.self)
        return str
    }

}

struct CHNetworkAnyDataDecoder: INetworkOperationDecoder {
    
    typealias T = Data
    
    func decode(_ type: Data.Type, from data: Data) throws -> Data {
        return data
    }
    
}
