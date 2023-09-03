//
//  CHImageView.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 27.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

@objcMembers class CHImageView: UIImageView {
    
    private weak var token: CHImageService.Token?
    private var urlRequest: URLRequest?
    
    func setImage(urlStr: String, defautImage: UIImage?) {
        let request = try? CHRequest(urlStr: urlStr)
        self.setImage(request: request, defautImage: defautImage)
    }
    
    func setImage(request: IRequest?, defautImage: UIImage? = nil) {
        guard let request = try? request?.asRequest(), request.url != self.urlRequest?.url else {
            if self.image == nil {
                self.image = defautImage
            }
            return
        }
        
        self.image = defautImage
        self.token?.cancell()
        self.urlRequest = request
        self.token = Challenge.shared.imageService.downloadImage(request: request) { [weak self] result in
            switch result {
            case .success(let image):
                self?.image = image
            case .failure(let error):
                print(error)
            }
        }
    }
        
}

extension CHImageView {
    
    func setImage(photo: CHFlickrPhoto?, size: CHFlickrPhoto.PhotoSize, defautImage: UIImage? = nil) {
        
        guard let photo = photo else {
            self.setImage(request: nil, defautImage: defautImage)
            return
        }
        
        let request = try? CHRequest(image: photo, size: size)
        self.setImage(request: request, defautImage: defautImage)
    }
    
}
