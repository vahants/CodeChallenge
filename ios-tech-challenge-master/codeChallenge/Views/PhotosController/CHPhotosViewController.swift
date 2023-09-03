//
//  CHPhotosViewController.swift
//  codeChallenge
//
//  Created by Vahan Tsogolakyan on 28.08.23.
//  Copyright © 2023 Fernando Suárez. All rights reserved.
//

import UIKit

@objc protocol IPhotosTableViewController {
    func getSort() -> CHFlickrPhotosNetworkWorker.FlickrPhotosSort
    func reloadSort(sort: CHFlickrPhotosNetworkWorker.FlickrPhotosSort)
}

class CHPhotosViewController: UIViewController {
    
    @IBOutlet weak private var navigationTopView: UIView!
    @IBOutlet weak private var segmentControll: UISegmentedControl!
    
    weak private var photosTablevVewController: IPhotosTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Flickr photos"
        self.segmentControll.setTitle("DatePostedDesc", forSegmentAt: 0)
        self.segmentControll.setTitle("DatePostedAsc", forSegmentAt: 1)
        self.segmentControll.setTitle("DateTakenDesc", forSegmentAt: 2)
        self.segmentControll.setTitle("DateTakenAsc", forSegmentAt: 3)
        self.segmentControll.setTitle("InterestingnessDesc", forSegmentAt: 4)
        self.segmentControll.setTitle("InterestingnessAsc", forSegmentAt: 5)
        self.segmentControll.setTitle("Relevance", forSegmentAt: 6)
        
        self.segmentControll.selectedSegmentIndex = self.photosTablevVewController?.getSort().rawValue ?? .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let vc = self.photosTablevVewController as? UIViewController
        var inset = vc?.additionalSafeAreaInsets ?? .zero
        inset.top = self.navigationTopView.frame.height
        vc?.additionalSafeAreaInsets = inset
    }
        
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TabelView" {
            self.photosTablevVewController = segue.destination as? IPhotosTableViewController
        }
    }
    
    //MARK: - User Action
    
    @IBAction private func didSelectSegmentControll(_ sender: Any) {
        guard let sort = CHFlickrPhotosNetworkWorker.FlickrPhotosSort(rawValue: self.segmentControll.selectedSegmentIndex) else {
            return
        }
        self.photosTablevVewController?.reloadSort(sort: sort)
    }

}

class SegmentedControl: UISegmentedControl {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
