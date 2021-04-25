//
//  favouritesViewController.swift
//  Roulette
//
//  Created by Mac User on 2021-04-22.
//

import Foundation
import UIKit

class favouritesViewController: UITableViewController {
    
    //create a connection to the viewmodel
    var viewModel = favouriteViewModel()
    
    //create a variable to hold the users favourites
    var usersFavourites:[FavouriteRestaurant]!
    
    //create a variable to track if its the first time opening
    var first_time_opened:Bool = false
    
    //every time the view controller opens other than the first time it will reload the data
    override func viewWillAppear(_ animated: Bool) {
        //check if the app has been opened before
//        print("ttttt:",first_time_opened)
        if first_time_opened == true{
            //update the fetched objects
            DispatchQueue.main.async {
                self.viewModel.grabFavourites()
            }
        }else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the delegate to self to get feedback from the viewmodel
        viewModel.delegate = self
        
        //call the method to set the data, this code will in turn have the delegate method returned
        viewModel.grabFavourites()
        
        //set the first time opened bool to true
        first_time_opened = true
    }
    
    //MARK: TABLEVIEW FUNCTIONS
    //this returns the number of data in the array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usersFavourites != nil {
            if usersFavourites.isEmpty == false {
                return usersFavourites.count
            }else {
                return 0
            }
        }else {
            return 0
        }
        
    }
    
    //this is for customizing the cell to our needs
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //grab the restaraunt data for the current cell index
        let currentRestaraunt:FavouriteRestaurant = usersFavourites[indexPath.row]
        
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "favouritesTableviewCell") as! favouriteTableViewCell
        
        //set a corner radius on the cell
        currentCell.dataView.layer.cornerRadius = 15
        
        //set the title
        currentCell.restarauntTitle.text = "\(currentRestaraunt.name ?? "N/A")"

        //set the rating
        if currentRestaraunt.rating == 5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "5StarRating")
            
        }else if currentRestaraunt.rating == 4.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "4HalfStarRating")

        }else if currentRestaraunt.rating == 4 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "4StarRating")

        }else if currentRestaraunt.rating == 3.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "3HalfStarRating")

        }else if currentRestaraunt.rating == 3 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "3StarRating")

        }else if currentRestaraunt.rating == 2.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "2HalfStarRating")
            
        }else if currentRestaraunt.rating == 2 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "2StarRating")

        }else if currentRestaraunt.rating == 1.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "1HalfStarRating")
            
        }else if currentRestaraunt.rating == 1 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "1StarRating")

        }else if currentRestaraunt.rating == 0 {
            //set the imageview

        }
        
        //set review count
        currentCell.totalReviewsLabel.text = "\(currentRestaraunt.reviewCount) reviews"
        
        //set the categories
        //this string will be the final representation of the tags label output string
        var finalString = ""
        for cat in currentRestaraunt.categories as! [NSDictionary] {
            
            let categoriesNSdict = currentRestaraunt.categories as! [NSDictionary]
            print("test123:",categoriesNSdict.count)
            
            //because of core data we have to search a NSdictionary for the categories
            finalString.append("\(cat["title"] ?? ""),")
            if cat == categoriesNSdict.last{
                finalString.append("\(cat["title"] ?? "")")
            }
            
            
        }
        //set the tags label
        currentCell.tagsLabel.text = finalString
        
        //set the pricerange
//        print("test:",currentRestaraunt.price)
        
        //create a variable holding the price text
        let priceString = "$$$$"
        var myMutableString = NSMutableAttributedString()
        
        if currentRestaraunt.price == "$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:1))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:2))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:3))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:4))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "" {
            currentCell.totalPriceLabel.text = "N/A"
        }
        
        //set the pickup/delivery availability
        //check if the restaraunt has 'transactions
        if currentRestaraunt.transactions != nil{
            
            for transaction in currentRestaraunt.transactions as! [NSArray] {
                
//                print(transaction)
                
                if transaction.contains("delivery") {
                    //set the available image for delivery
                    currentCell.pickupImageView.image = #imageLiteral(resourceName: "check-mark")
                    currentCell.pickupImageView.tintColor = #colorLiteral(red: 0, green: 0.6039215686, blue: 0.03529411765, alpha: 1)
                    
                }else {
                    //set the image to be 'not available'
                    currentCell.pickupImageView.image = #imageLiteral(resourceName: "cancel")
                    currentCell.pickupImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
                    
                }
                
                if transaction.contains("pickup") {
                    //set the available image for pickup
                    currentCell.deliveryImageView.image = #imageLiteral(resourceName: "check-mark")
                    currentCell.deliveryImageView.tintColor = #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1)
                    
                }else {
                    //set the image to be 'not available'
                    currentCell.deliveryImageView.image = #imageLiteral(resourceName: "cancel")
                    currentCell.deliveryImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
                }
            }
            
        
        }else {
            //set both the pickup and delivery logo to be red x's
            //set the image to be 'not available' for delivery
            currentCell.deliveryImageView.image = #imageLiteral(resourceName: "cancel")
            currentCell.deliveryImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
            //set the image to be 'not available' for pickup
            //set the image to be 'not available'
            currentCell.pickupImageView.image = #imageLiteral(resourceName: "cancel")
            currentCell.pickupImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
            
            
        }
        
        
        return currentCell
        
    }
    
    //this is for selecting a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
extension favouritesViewController:favouriteViewModelDelegate{
    
    func returnAllFavourites(favouriteRestaurants: [FavouriteRestaurant]?) {
        //set the data top-level
        usersFavourites = favouriteRestaurants
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}