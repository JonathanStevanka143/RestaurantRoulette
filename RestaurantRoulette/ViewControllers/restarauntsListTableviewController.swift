//
//  restarauntsListTableviewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData

class restaurantsListTableviewController: UIViewController {
    
    //FIRST PHASE OUTLETS
    //nav bar items
    @IBOutlet var editButton: UIButton!
    //views
    @IBOutlet var tableView: UITableView!
    //buttons
    @IBOutlet var continueButton: UIButton!
    
    //FIRST PHASE VARIABLES
    //this holds the map coords that the user wanted to use
    var centerMapCoord: CLLocationCoordinate2D!
    //filter options from the phone, set by the sending VC
    var filterOptions:FilterSettings!
    //this array of categories is what the user currently wants to search nearby with
    var categories:[Categories]!
    //hook up the view model(where updates will be made etc)
    var ViewModel = restarauntsViewModel()
    //this will hold all of the tableview data
    var restaurants:[restaurant]! = []
    
    //SECOND PHASE VARIABLES
    //this holds the currently selected cell number
    var currentlySelectedCell:IndexPath! = nil
    
    
    override func viewDidLoad() {
        
        ViewModel.delegate = self
        
        //test grabbing the locations
        //tableview delegete set inside return delegate function
        ViewModel.getCloseRestaraunts(latitude: "\(centerMapCoord.latitude)", longitude: "\(centerMapCoord.longitude)",options: filterOptions,categories: categories)
        
        //set the tableview delegate
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    
    //MARK: BUTTON ACTIONS
    @IBAction func editButtonPressed(_ sender: Any) {
        //check to see if the table is in editing mode or not
        if tableView.isEditing == false{
            //begin the editing
            tableView.isEditing = true
            //set the text on the button to 'done'
            editButton.setTitle("Done", for: .normal)
        }else {
            //end the editing
            tableView.isEditing = false
            //set the text on the button back to 'edit'
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    
    var phase2:Bool! = false
    var hasSpun:Bool! = false
    @IBAction func spinTheWheelButtonPressed(_ sender: Any) {
        //set the button to be inactive
        continueButton.isEnabled = false
        
        if phase2 == true {
            //1.disable scrolling
            //2.set the button to say "remove & spin"
            continueButton.setTitle("Remove & Spin", for: .normal)
            
            if hasSpun == true {
                
                //remove the restaraunt from the list so it cant be used again
                let removeThis = restaurants[currentlySelectedCell.row]
                
                restaurants.removeAll{ $0 == removeThis }
                
                //reset the tableview
                resetAndShuffle(completionHandler: {
                    didReset in
                    
                    self.tableView.layoutIfNeeded()
                    
                    if didReset == true {
                        self.spinthewheel()
                    }
                    
                })
            
                //set the continuebutton to be enabled again
                continueButton.isEnabled = true
                
                
            }else {
                //calling this function 'spins' the wheel
                spinthewheel()
                
                //set the continuebutton to be enabled again
                continueButton.isEnabled = true
                
                hasSpun = true
            }
            
        }else{
            //hide the tableview
            tableView.isHidden = true
            
            //1.set the edit button to be hidden
            //2.set the 'spinbutton' to be "spin the wheel"
            //3.double the tableviewcells and then make sure the scrollview is at the top
            //4.shuffle the restaraunts
            //5.change the phase so we can control flow with the button
            editButton.isHidden = true
            continueButton.setTitle("Spin the wheel", for: .normal)
            restaurants += restaurants
            restaurants = restaurants.shuffled()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.continueButton.isEnabled = true
                self.tableView.isHidden = false
                self.tableView.isScrollEnabled = false
                self.phase2 = true
            }
        }
        
    }
    
    //MARK: WHEEL SPIN FUNCTION
    func spinthewheel(){
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        
        UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            self.tableView.contentOffset = CGPoint(x: 0, y: -125)
            self.tableView.layoutIfNeeded()
            
            generator.impactOccurred()
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: 650)
                self.tableView.layoutIfNeeded()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 1300)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        
                        self.tableView.setContentOffset(CGPoint(x: 0, y: 1950), animated: false)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        self.grabSelectedRestaraunt()
                        
                    })
                    
                })
                
            })
            
        })
        
        
    }
    
    //MARK: GRAB THE 'WINNING' INDEXPATH
    func grabSelectedRestaraunt(){
        
        //1.grab the visible tableview cells
        //2.pick the middle most number
        //3.either display a view or just automatically bring them back to the main screen
        
        //grab the contentoffset before reload
        let visibleCells = tableView.indexPathsForVisibleRows
        print(Int(visibleCells!.count / 2))
        tableView.selectRow(at: visibleCells![Int(visibleCells!.count / 2)], animated: true, scrollPosition: .middle)
        //set the currently selectedRow, used to remove and view cells
        currentlySelectedCell = visibleCells![Int(visibleCells!.count / 2)]
    }
    
    //MARK: RE-SETTING THE TABLEVIEW
    func resetAndShuffle(completionHandler: @escaping (Bool) -> ()){
        //1.shuffle the data in the list
        //2.scroll to the top cell
        //3.reload the data
        if restaurants.count > 20 {
            restaurants += restaurants
        }
        restaurants = restaurants.shuffled()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            completionHandler(true)
        }
    
    }
    
    
}

extension restaurantsListTableviewController: UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if restaurants.isEmpty == false {
            return restaurants.count
        }else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if tableView.isEditing == true {
            return .delete
        }else{
            return .none
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            
            //remove the selected cell
            self.restaurants.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            
            //set the continue button with the total left
            continueButton.setTitle("Continue(\(restaurants.count))", for: .normal)
            
            break
        default:
            //code goes here
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //grab the restaraunt data for the current cell index
        let currentRestaraunt:restaurant = restaurants[indexPath.row]
        
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

extension restaurantsListTableviewController:restarauntsViewModelDelegate {
    
    //this function will return our converted restaraunts
    func returnCloseRestaraunts(closeRestaraunts: [restaurant]?) {
        
        self.restaurants = closeRestaraunts
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            //set the continue button with the total left
            self.continueButton.setTitle("Continue(\(self.restaurants.count))", for: .normal)
        }
        
        
    }
    
    
    
    
}
