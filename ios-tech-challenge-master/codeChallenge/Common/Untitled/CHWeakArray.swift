//
//  CHWeakArray.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 26.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

class CHWeakArray<T> {

    let weakRefarray = NSPointerArray.weakObjects()
    
    var objects: [T] {
        return self.weakRefarray.allObjects as! [T]
    }
    
    func addObject(_ listener: T) {
        let pointer = Unmanaged.passUnretained(listener as AnyObject).toOpaque()
        self.weakRefarray.addPointer(pointer)
    }
    
    func removeObject(_ listener: T) {
        for (index, object) in self.objects.enumerated() {
            if (object as AnyObject) === (listener as AnyObject) {
                self.weakRefarray.removePointer(at: index)
                break
            }
        }
    }
    
    func forEach(_ body: (T) -> Void) {
        self.objects.forEach { obj in
            body(obj)
        }
    }
    
    func flatMap<ElementOfResult>(_ transform: (T) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        var result = [ElementOfResult]()
        self.forEach {
            if let t = try? transform( $0) {
                result.append(t)
            }
        }
        return result
    }
    
    func first(where predicate: (T) -> Bool) -> T? {
        self.objects.first(where: predicate)
    }
    
}
