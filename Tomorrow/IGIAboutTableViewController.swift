//
//  IGIAboutTableViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 3/19/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGIAboutTableViewController: UITableViewController {
    
    @IBOutlet weak var thanks: UILabel!
    
    // We should never be nil here!
    var userObject: IGIUser = IGIUser.getCurrentUser()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if userObject.getFirstName() != "" {
            thanks.text = "\(userObject.getFirstName())! Thanks so much for downloading Tomorrow. I'm David, the creator. Please contact me if you have any feedback and consider leaving a review on iTunes to show support-it helps (a ton)!"
        } else {
            thanks.text = "Thanks so much for downloading Tomorrow. I'm David, the creator. Please contact me if you have any feedback and consider leaving a review on iTunes to show support-it helps (a ton)!"
        }
    }
}
