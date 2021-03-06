
//  IGIAboutTableViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 3/19/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import StoreKit

class IGIAboutTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var thanks: UILabel!
    @IBOutlet weak var completed: UILabel!
    
    @IBOutlet weak var iapDisabled: UILabel!
    @IBOutlet weak var modestView: UIView!
    @IBOutlet weak var generousView: UIView!
    @IBOutlet weak var massiveView: UIView!
    
    @IBOutlet weak var modestTitle: UILabel!
    @IBOutlet weak var modestCost: UIButton!
    
    @IBOutlet weak var generousTitle: UILabel!
    @IBOutlet weak var generousCost: UIButton!
    
    @IBOutlet weak var massiveTitle: UILabel!
    @IBOutlet weak var massiveCost: UIButton!
    
    @IBOutlet weak var version: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var fetchedProducts = []
    
    // We should never be nil here!
    var userObject: IGIUser = IGIUser.getCurrentUser()!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modestView.userInteractionEnabled = false
        generousView.userInteractionEnabled = false
        massiveView.userInteractionEnabled = false
        
        fetchProductInfo()
        
        if let vStr = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String, bStr = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            version.text = "Version \(vStr) (\(bStr))"
        } else {
            version.text = ":)"
        }
        
        // simple greeting
        if userObject.getFirstName() != "" {
            thanks.text = "\(userObject.getFirstName())! Thanks so much for downloading Tomorrow. I'm David, the creator. Please contact me if you have any feedback!"
        } else {
            thanks.text = "Thanks so much for downloading Tomorrow. I'm David, the creator. Please contact me if you have any feedback!"
        }
        
        // completed count
        let count = IGIGoal.countCompletedTasks()
        
        if count == 0 {
            completed.text = "You haven't completed any tasks. You can do it!"
        } else {
            var append = ""
            if count > 1 {
                append = "s"
            }
            completed.text = "You've completed \(count) task\(append) using Tomorrow!"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: "About Screen")
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    }
    
    @IBAction func unwindToAboutViewController(sender: UIStoryboardSegue) {
        // close
    }
    
    // MARK: Products Request Delegate
    
    func fetchProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.iapDisabled.alpha = 0.0
                self.modestView.alpha = 0.2
                self.generousView.alpha = 0.2
                self.massiveView.alpha = 0.2
            })
            activity.startAnimating()
        
            let request = SKProductsRequest(productIdentifiers: NSSet(array: ["IGIGENEROUS01", "IGIMASSIVE01", "IGIMODEST01"]) as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.iapDisabled.alpha = 1.0
                self.modestView.alpha = 0.2
                self.generousView.alpha = 0.2
                self.massiveView.alpha = 0.2
            })
        }
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        fetchedProducts = response.products
        
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.alwaysShowsDecimalSeparator = true
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        if fetchedProducts.count != 0 {
            for item in fetchedProducts {
                let product = item as? SKProduct
                formatter.locale = product!.priceLocale
                
                let title = product!.localizedTitle
                let price = formatter.stringFromNumber(product!.price)
                
                switch product!.productIdentifier {
                case "IGIGENEROUS01":
                    generousTitle.text = title
                    generousCost.setTitle(price, forState: UIControlState.Normal)
                case "IGIMASSIVE01":
                    massiveTitle.text = title
                    massiveCost.setTitle(price, forState: UIControlState.Normal)
                case "IGIMODEST01":
                    modestTitle.text = title
                    modestCost.setTitle(price, forState: UIControlState.Normal)
                default:
                    break // should not have other products here
                }
            }
            
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.modestView.alpha = 1.0
                self.generousView.alpha = 1.0
                self.massiveView.alpha = 1.0
            })
            modestView.userInteractionEnabled = true
            generousView.userInteractionEnabled = true
            massiveView.userInteractionEnabled = true
        } else {
            self.iapDisabled.text = "The tip jar is unfortunately closed due to an unknown error. Please try again later."
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.iapDisabled.alpha = 1.0
            })
        }
    
        activity.stopAnimating()
    }
    
    func productForId(identifier: String) -> SKProduct? {
        for item in fetchedProducts {
            let product = item as? SKProduct
            if product!.productIdentifier == identifier {
                return product
            }
        }
        return nil
    }
    
    func purchaseStarted() {
        activity.startAnimating()
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.modestView.alpha = 0.2
            self.generousView.alpha = 0.2
            self.massiveView.alpha = 0.2
        })
        modestView.userInteractionEnabled = false
        generousView.userInteractionEnabled = false
        massiveView.userInteractionEnabled = false
    }
    
    func purchaseEnded() {
        activity.stopAnimating()
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.modestView.alpha = 1.0
            self.generousView.alpha = 1.0
            self.massiveView.alpha = 1.0
        })
        modestView.userInteractionEnabled = true
        generousView.userInteractionEnabled = true
        massiveView.userInteractionEnabled = true
    }
    
    func purchaseItemWithIdentifier(identifier: String) {
        purchaseStarted()
        let product = productForId(identifier)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: product))
    }
    
    // MARK: Payment
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("Transaction updated")
        
        for transaction in transactions as! [SKPaymentTransaction] {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchasing:
                println("Purchasing item!")
            case SKPaymentTransactionState.Purchased:
                println("Item purchased!")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "kDidLeaveDonation")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                purchaseEnded()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
                if let product = productForId(transaction.payment.productIdentifier) {
                    let tracker = GAI.sharedInstance().defaultTracker
                    let currencyCode = product.priceLocale.objectForKey(NSLocaleCurrencyCode) as! String
                    let revenue = product.price.doubleValue - (product.price.doubleValue * 0.30)
                    tracker.send(GAIDictionaryBuilder.createTransactionWithId(transaction.transactionIdentifier, affiliation: "In-app Store", revenue: revenue, tax: 0, shipping: 0, currencyCode:currencyCode).build() as [NSObject: AnyObject])
                    tracker.send(GAIDictionaryBuilder.createItemWithTransactionId(transaction.transactionIdentifier, name: product.localizedTitle, sku: product.productIdentifier, category: "Donation", price: product.price, quantity: 1, currencyCode:currencyCode).build() as [NSObject: AnyObject])
                }
            case SKPaymentTransactionState.Restored:
                println("Item restored!")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "kDidLeaveDonation")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                purchaseEnded()
            case SKPaymentTransactionState.Failed:
                if transaction.error.code != SKErrorPaymentCancelled {
                    println("Transaction canceled!")
                }
                purchaseEnded()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    // MARK: Actions
    @IBAction func rateActionPressed(sender: AnyObject) {
        let build = GAIDictionaryBuilder.createEventWithCategory("milestone", action: "rate_pressed", label: nil, value: nil).build()
        GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
        
        UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/tomorrow-to-do-list-for-new/id963592550?ls=1&mt=8")!)
    }
    
    @IBAction func modestActionPressed(sender: AnyObject) {
        purchaseItemWithIdentifier("IGIMODEST01")
    }
    
    @IBAction func generousActionPressed(sender: AnyObject) {
        purchaseItemWithIdentifier("IGIGENEROUS01")
    }
    
    @IBAction func massiveActionPressed(sender: AnyObject) {
        purchaseItemWithIdentifier("IGIMASSIVE01")
    }
    
    @IBAction func twitterAction(sender: AnyObject) {
        
        if openURL(NSURL(string: "twitter://user?screen_name=xmcgraw")!) {
            // opened!
        } else if openURL(NSURL(string: "tweetbot://xmcgraw/user_profile/xmcgraw")!) {
            // opened!
        } else {
            // open simple page
            openURL(NSURL(string: "http://twitter.com/xmcgraw")!)
        }
        
    }

    @IBAction func emailAction(sender: AnyObject) {
        var recip = "mailto:dave@moonlitsolutions.com?subject=Tomorrow - I have some feedback for you"
        recip = recip.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        UIApplication.sharedApplication().openURL(NSURL(string: recip)!)
    }
    
    private func openURL(url: NSURL) -> Bool {
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
            return true
        } else {
            return false
        }
    }
}
