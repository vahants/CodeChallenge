//
//  FlickrPhoto.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 27.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import Foundation

@objcMembers class CHFlickrPhoto: NSObject, Decodable {
    
    @objc enum PhotoSize: Int {
        case thumbnail
        case medium
        case large
        case original
        
        var suffix: String {
            switch self {
            case .thumbnail:
                return "s"
            case .medium:
                return "z"
            case .large:
                return "b"
            case .original:
                return "o"
            }
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case datetaken = "datetaken"
        case descriptionPhoto = "description"
        case id = "id"
        case owner = "owner"
        case secret = "secret"
        case server = "server"
        case tags = "tags"
        case title = "title"
    }
    
    private enum DescriptionCodingKeys: String, CodingKey {
        case content = "_content"
    }
    
    let datetaken: Date?
    let descriptionPhoto: String?
    let id: String
    let owner: String?
    let secret: String?
    let server: String?
    let tags: String?
    let title: String?
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        self.datetaken = try? container.decodeIfPresent(Date.self, forKey: .datetaken) ?? nil
        self.owner = try container.decodeIfPresent(String.self, forKey: .owner)
        self.secret = try container.decodeIfPresent(String.self, forKey: .secret)
        self.server = try container.decodeIfPresent(String.self, forKey: .server)
        self.tags = try container.decodeIfPresent(String.self, forKey: .tags)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        
        let description = try? container.nestedContainer(keyedBy: DescriptionCodingKeys.self, forKey: .descriptionPhoto)
        self.descriptionPhoto = try? description?.decodeIfPresent(String.self, forKey: .content) ?? nil
        super.init()
    }
    
    
}
