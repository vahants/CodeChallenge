//
//  CHTitileTableViewCell.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 02.09.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

class CHTitileTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }

}
