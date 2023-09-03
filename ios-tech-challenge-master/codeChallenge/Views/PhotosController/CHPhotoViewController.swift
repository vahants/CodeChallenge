//
//  CHPhotoViewController.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 28.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

class CHPhotoViewController: UITableViewController {
    
    private var photo: CHFlickrPhoto?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = UITableView.automaticDimension;
        registerCell()
    }
    
    private func registerCell() {
        let cellNib: UINib = UINib.init(nibName: "CHTitileTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "CHTitileTableViewCell")
        
        let cellNibPhoto: UINib = UINib.init(nibName: "CHPhotoTableViewCell", bundle: nil)
        tableView.register(cellNibPhoto, forCellReuseIdentifier: "CHPhotoTableViewCell")
        
        let cellNibDescription: UINib = UINib.init(nibName: "CHDescriptionTableViewCell", bundle: nil)
        tableView.register(cellNibDescription, forCellReuseIdentifier: "CHDescriptionTableViewCell")
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return UIScreen.main.bounds.width
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return UIScreen.main.bounds.width
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0: return titleCell(from: tableView, at: indexPath)
            case 1: return photoCell(from: tableView, at: indexPath)
            case 2: return descriptionCell(from: tableView, at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    private func titleCell(from tableView: UITableView, at indexPath: IndexPath) -> CHTitileTableViewCell {
        let titileTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CHTitileTableViewCell", for: indexPath) as! CHTitileTableViewCell

        titileTableViewCell.setTitle(title: photo?.title ?? "")
        return titileTableViewCell
    }
    
    private func photoCell(from tableView: UITableView, at indexPath: IndexPath) -> CHPhotoTableViewCell {
        let photoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CHPhotoTableViewCell", for: indexPath) as! CHPhotoTableViewCell

        photoTableViewCell.setPhoto(photo: photo)
        return photoTableViewCell
    }
    
    private func descriptionCell(from tableView: UITableView, at indexPath: IndexPath) -> CHDescriptionTableViewCell {
        let descriptionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CHDescriptionTableViewCell", for: indexPath) as! CHDescriptionTableViewCell

        descriptionTableViewCell.setDescription(description: photo?.descriptionPhoto ?? "")
        return descriptionTableViewCell
    }
    
    @objc func setPhoto(photo: CHFlickrPhoto) {
        self.photo = photo
    }
}
