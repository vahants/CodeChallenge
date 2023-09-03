//
//  CHPhotoTableViewCell.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 02.09.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

class CHPhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var photoImgeView: CHImageView!
//    private var photo: CHFlickrPhoto?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.photoImgeView.setImage(photo: self.photo, size: .large)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPhoto(photo: CHFlickrPhoto?) {
        self.photoImgeView.setImage(photo: photo, size: .large)
    }
}
