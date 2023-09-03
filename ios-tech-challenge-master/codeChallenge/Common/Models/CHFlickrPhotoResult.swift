//
//  CHFlickrPhotoResult.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 27.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

@objcMembers class CHFlickrPhotoResult: NSObject, Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case start = "stat"
        case page = "photos"
    }
    
    let start: String
    let page: CHFlickrPhotoPageResult
    
}
