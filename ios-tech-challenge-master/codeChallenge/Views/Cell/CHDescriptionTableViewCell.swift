//
//  CHDescriptionTableViewCell.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 02.09.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

class CHDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDescription(description: String) {
        descriptionLabel?.text = description
    }
    
}
