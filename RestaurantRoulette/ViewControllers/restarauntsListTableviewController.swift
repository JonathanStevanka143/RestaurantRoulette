//
//  restarauntsListTableviewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData

class restarauntsListTableviewController: UIViewController {
    
    //views
    @IBOutlet var tableView: UITableView!
    
    //buttons
    @IBOutlet var continueButton: UIButton!
    
    //this holds the map coords that the user wanted to use
    var centerMapCoord: CLLocationCoordinate2D!
    
    //filter options from the phone, set by the sending VC
    var filterOptions:FilterSettings!
    
    //hook up the view model(where updates will be made etc)
    var ViewModel = restarauntsViewModel()
    
    //this will hold all of the tableview data
    var restaraunts:[restaurant]! = []
    
    override func viewDidLoad() {
                
        ViewModel.delegate = self
        
        //test grabbing the locations
        //tableview delegete set inside return delegate function
        ViewModel.getCloseRestaraunts(latitude: "\(centerMapCoord.latitude)", longitude: "\(centerMapCoord.longitude)",options: filterOptions)
                
        //set the tableview delegate
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    //MARK: BUTTON ACTIONS
    @IBAction func spinTheWheelButtonPressed(_ sender: Any) {
        
//        print("t2:",self.tableView.frame)
//
//        let generator = UIImpactFeedbackGenerator(style: .heavy)
//
//        generator.impactOccurred()
//
//        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
//
//            self.tableView.frame.origin.y = 140
//
//
//        }, completion: { _ in
//
//            UIView.animate(withDuration: 3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
//
//                self.tableView.frame.origin.y = -3000
//
//            }, completion: { _ in
//                generator.impactOccurred()
//
//
//            })
//
//        })
        
    }
    
    
}

extension restarauntsListTableviewController: UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if restaraunts.isEmpty == false {
            return restaraunts.count
        }else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //grab the restaraunt data for the current cell index
        let currentRestaraunt:restaurant = restaraunts[indexPath.row]
        
        let testCell = tableView.dequeueReusableCell(withIdentifier: "restaurantTableviewCell") as! restarauntTableViewCell
        
        //set the title
        testCell.restarauntTitle.text = "\(currentRestaraunt.name)"
        
        //set the distance
        if currentRestaraunt.distance < 1000 {
            
            let distance: Int = Int(currentRestaraunt.distance)
            
            //set the distance in meteres
            testCell.distanceLabel.text = "\(distance) m"
            
        }else {
            let distance: Double = Double(currentRestaraunt.distance / 1000)
            let totaldistanceString: String = String(format: "%.1f", distance)
            //set the distance in km
            testCell.distanceLabel.text = "\(totaldistanceString) km"
            
        }
        
        
        //hide the half cells
        testCell.halfLikeView1.isHidden = true
        testCell.halfLikeView2.isHidden = true
        testCell.halfLikeView3.isHidden = true
        testCell.halfLikeView4.isHidden = true
        testCell.halfLikeView5.isHidden = true
        
        
        //set the rating
        if currentRestaraunt.rating == 5 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            testCell.favView4.backgroundColor = UIColor.red
            testCell.favView5.backgroundColor = UIColor.red
            
        }else if currentRestaraunt.rating == 4.5 {
            
            //1. set the cells up to the 4rd fav cell
            //2. on the 4th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            testCell.favView4.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView5.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 4 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            testCell.favView4.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 3.5 {
            
            //1. set the cells up to the 3rd fav cell
            //2. on the 3th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView4.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 3 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 2.5 {
            
            //1. set the cells up to the 2rd fav cell
            //2. on the 2th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView3.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
            
        }else if currentRestaraunt.rating == 2 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 1.5 {
            
            //1. set the cells up to the 1rd fav cell
            //2. on the 1th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView2.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
            
        }else if currentRestaraunt.rating == 1 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 0.5 {
            
            //1. on the 1th fav cell set the halflikeView to be unhidden
            
            //1
            //set the correct cell to be hidden
            testCell.halfLikeView1.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView1.backgroundColor = UIColor.lightGray
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
            
        }else if currentRestaraunt.rating == 0 {
            //set the buttons to grey
            testCell.favView1.backgroundColor = UIColor.lightGray
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
        }
        
        
        //set review count
        testCell.totalReviewsLabel.text = "\(currentRestaraunt.review_count) reviews"
        
        //set the categories
        //this string will be the final representation of the tags label output string
        var finalString = ""
        for cat in currentRestaraunt.categories {
            if cat == currentRestaraunt.categories.last {
                finalString.append("\(cat.title)")
            }else {
                finalString.append("\(cat.title),")
            }
        }
        //set the tags label
        testCell.tagsLabel.text = finalString
        
        //set the pricerange
        print("test:",currentRestaraunt.price)
        
        //create a variable holding the price text
        let priceString = "$$$$"
        var myMutableString = NSMutableAttributedString()
        
        if currentRestaraunt.price == "$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:1))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:2))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:2))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:3))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "" {
            testCell.totalPriceLabel.text = "$$$$"
        }
        
        //set the pickup/delivery availability
        //check if the restaraunt has 'transactions'
        if currentRestaraunt.transactions.isEmpty == false{
            
            if currentRestaraunt.transactions.contains("delivery") {
                //set the available image for delivery
                testCell.pickupImageView.image = #imageLiteral(resourceName: "check-mark")
                testCell.pickupImageView.tintColor = UIColor.green
                
            }else {
                //set the image to be 'not available'
                testCell.pickupImageView.image = #imageLiteral(resourceName: "cancel")
                testCell.pickupImageView.tintColor = UIColor.red
                
            }
            
            if currentRestaraunt.transactions.contains("pickup") {
                //set the available image for pickup
                testCell.deliveryImageView.image = #imageLiteral(resourceName: "check-mark")
                testCell.deliveryImageView.tintColor = UIColor.green
                
            }else {
                //set the image to be 'not available'
                testCell.deliveryImageView.image = #imageLiteral(resourceName: "cancel")
                testCell.deliveryImageView.tintColor = UIColor.red
            }
            
            
        }
        
        
        return testCell
        
    }
    
}

extension restarauntsListTableviewController:restarauntsViewModelDelegate {
    
    //this function will return our converted restaraunts
    func returnCloseRestaraunts(closeRestaraunts: [restaurant]?) {
        
        self.restaraunts = closeRestaraunts
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    
    
    
}
