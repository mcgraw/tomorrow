//
//  IGIMapViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 3/23/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import MapKit
import Spring

class IGIMapViewController: GAITrackedViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapContainer: SpringView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 37.686033, -97.332934
        let coord = CLLocationCoordinate2DMake(37.686033, -97.332934)
        let span = MKCoordinateSpanMake(1, 1)
        let region = MKCoordinateRegionMakeWithDistance(coord, 8000, 8000)
        mapView.setRegion(region, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        screenName = "About Map Screen"
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first as? UITouch {
            let point = touch.locationInView(self.view)
            if !CGRectContainsPoint(mapView.frame, point) {
                mapContainer.animation = "fall"
                mapContainer.animate()
                
                self.performSegueWithIdentifier("unwindToAboutSegue", sender: nil)
            }
        }
    }
}
