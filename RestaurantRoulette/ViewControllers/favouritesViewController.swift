//
//  favouritesViewController.swift
//  Roulette
//
//  Created by Mac User on 2021-04-22.
//

import Foundation
import UIKit

class favouritesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: OUTLETS
    @IBOutlet var TableViewHolder: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var spinFavouriteButton: UIButton!
    
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
        
        //call the tableview delegates
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: BUTTON PRESS
    
    @IBAction func spinFavouritesButtonPressed(_ sender: Any) {
        
        //convert our core data objects here that way all we have to do is send it to the spinViewController
        //create an array holding convert restaurants
        var restaurantArray:[restaurant] = []
        if usersFavourites != nil {
            for userFav in usersFavourites {
                
                
                let id = userFav.id!
                let name = userFav.name!
                let url = userFav.url!
                let review_count = Int(userFav.reviewCount)
                let rating = userFav.rating
                let phone = userFav.phone!
                let display_phone = userFav.displayPhone!
                let price = userFav.price!
                
                //create a string to hold the transactions
                var transactionString:[String] = []
                if userFav.transactions != nil {
//                    print("test123:", userFav.transactions as? [[String]])
                    for trans in userFav.transactions as! [[String]] {
                        transactionString.append(contentsOf: trans)
                    }
                }
                
                //convert the categories into readable files
                //create a variable to grab all categories
                let categories = userFav.categories
                //create an empty array to hold the categories
                var categoriesArray:[category] = []
                if categories != nil {
                    for cat in categories as! [[String:String]] {
                        let newCategory = category(alias: cat["title"] ?? "", title: cat["title"] ?? "")
                        categoriesArray.append(newCategory)
                    }
                }
                
                let location = userFav.location as! location
                
                
                                
                //convert the data
                let convertedFavourite:restaurant = restaurant(id: id, name: name, url: url, review_count: review_count, rating: rating, phone: phone, display_phone: display_phone, distance: 0, price: price, categories: categoriesArray, location: location, transactions: transactionString)
                
                //add the new converted model to the array
                restaurantArray.append(convertedFavourite)
            }
        }
        
        print("cnt:",restaurantArray.count)
        
    }
    
    
    
    //MARK: TABLEVIEW FUNCTIONS
    //this returns the number of data in the array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usersFavourites != nil {
            if usersFavourites.isEmpty == false {
                //show the tableview holder and siplay the message
                TableViewHolder.isHidden = false
                return usersFavourites.count
            }else {
                //hide the tableview holder and siplay the message
                TableViewHolder.isHidden = true
                return 0
            }
        }else {
            return 0
        }
        
    }
    
    //this will allow us to delete favourites right from the page and allow the user to save changes
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //connect the object context from the appdelegate
        let moc = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        switch editingStyle {
        case .delete:
            
            //remove the selected object from the view context
            let objectForDelete = usersFavourites[indexPath.row]
            //delete the object into oblivion from the MOC
            moc?.delete(objectForDelete)
            //remove the selected cell
            self.usersFavourites.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            //save the context
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            
            break
        default:
            //code goes here
            break
        }
        
    }
    
    //this is for customizing the cell to our needs
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
//            print("test123:",categoriesNSdict.count)
            
            //because of core data we have to search a NSdictionary for the categories
            if cat == categoriesNSdict.last{
                finalString.append("\(cat["title"] ?? "")")
            }else{
                finalString.append("\(cat["title"] ?? ""),")
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
                                
                if transaction.contains("delivery") {
                    //set the available image for delivery
                    currentCell.deliveryImageView.image = #imageLiteral(resourceName: "check-mark")
                    currentCell.deliveryImageView.tintColor = #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1)
                }
                
                if transaction.contains("pickup") {
                    //set the available image for pickup
                    
                    currentCell.pickupImageView.image = #imageLiteral(resourceName: "check-mark")
                    currentCell.pickupImageView.tintColor = #colorLiteral(red: 0, green: 0.6039215686, blue: 0.03529411765, alpha: 1)
                    
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //grab the cell connected with the clicked cell
        let currentModel = usersFavourites[indexPath.row]
//        //check if it can be converted to a URL
        if let websiteURL = URL(string: currentModel.url ?? ""){
            //launch the web view to the internet
            UIApplication.shared.open(websiteURL, options: [:], completionHandler: nil)

        }else{
            //make a popup say invalid or something?

        }
        
        print(currentModel.location as! location)
        
    }
    
}
extension favouritesViewController:favouriteViewModelDelegate{
    
    func returnAllFavourites(favouriteRestaurants: [FavouriteRestaurant]?) {
        //set the data top-level
        usersFavourites = favouriteRestaurants
        
        DispatchQueue.main.async {
            if self.usersFavourites.count != 0{
                self.TableViewHolder.isHidden = false
            }
            self.tableView.reloadData()
        }
    }
    
}
