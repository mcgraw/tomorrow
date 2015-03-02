//
//  IGIMessageViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 3/2/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

protocol IGIMessageViewDelegate {
    func cancelPressed()
    func acceptPressed()
}

class IGIMessageViewController: UIViewController {
    
    var delegate: IGIMessageViewDelegate?
    
    @IBAction func cancelPressed(sender: AnyObject) {
        delegate?.cancelPressed()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissPressed(sender: AnyObject) {
        delegate?.acceptPressed()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
