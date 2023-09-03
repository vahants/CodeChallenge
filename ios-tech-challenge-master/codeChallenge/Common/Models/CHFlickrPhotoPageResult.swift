//
//  CHFlickrPhotoPageResult.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 27.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

@objcMembers class CHFlickrPhotoPageResult: NSObject, Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case photos = "photo"
        case total = "total"
    }
    
    let page: Int
    let pages: Int
    let perpage: Int?
    let photos: [CHFlickrPhoto]
    let total: Int
        
}
