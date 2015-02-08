//
//  IGITimelineViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGITimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IGITimelineNodeDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Table View 
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timelineItemId") as UITableViewCell
        if cell.contentView.subviews.count > 0 {
            // prepare for reuse & pass in new data
            let nodeView = cell.contentView.subviews[0] as IGITimelineNodeView
            nodeView.prepareForReuse()
        } else {
            let nodeView = IGITimelineNodeView(state: .Task, withTask: "Write Chapter 5")
            
            if indexPath.row == 0 {
                nodeView.playTimelineAnimationDelayed(delay: 1.0)
            }
            
            cell.contentView.addSubview(nodeView)
            
            nodeView.delegate = self
            nodeView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        }
        
        return cell
    }

    // MARK: Timeline Delegate
    func nodeDidCompleteAnimation() {
        // Play the next cell
        for cell in tableView.visibleCells() {
            var nodeView = cell.contentView.subviews[0] as IGITimelineNodeView
            if !nodeView.revealAnimationComplete {
                nodeView.playTimelineAnimationDelayed(delay: 0.15)
                
                if var path = tableView.indexPathForCell(cell as UITableViewCell) {
                    // smooth out the scroll animation
                    UIView.animateWithDuration(1.0, animations: {
                        self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    })
                }
                break;
            }
        }
    }
    
}
              