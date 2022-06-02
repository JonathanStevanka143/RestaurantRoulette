//
//  restaurant.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData

class restaurant: NSObject,NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(url, forKey: "url")
        coder.encode(categories, forKey: "categories")
        coder.encode(review_count, forKey: "review_count")
        coder.encode(rating, forKey: "rating")
        coder.encode(location, forKey: "location")
        coder.encode(phone, forKey: "phone")
        coder.encode(display_phone, forKey: "display_phone")
        coder.encode(distance, forKey: "distance")
        coder.encode(price, forKey: "price")
        coder.encode(transactions, forKey: "transactions")
        coder.encode(is_favourite, forKey: "is_favourite")
    }
    
    required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: "id") as! String
        self.name = coder.decodeObject(forKey: "name") as! String
        self.url = coder.decodeObject(forKey: "url") as! String
        self.categories = coder.decodeObject(forKey: "categories") as! [category]
        self.review_count = coder.decodeObject(forKey: "review_count") as! Int
        self.rating = coder.decodeObject(forKey: "rating") as! Double
        self.location = coder.decodeObject(forKey: "location") as! NSObject as! location
        self.phone = coder.decodeObject(forKey: "phone") as! String
        self.display_phone = coder.decodeObject(forKey: "display_phone") as! String
        self.distance = coder.decodeObject(forKey: "distance") as! Double
        self.price = coder.decodeObject(forKey: "price") as! String
        self.transactions = coder.decodeObject(forKey: "transactions") as! [String]
        self.is_favourite = coder.decodeObject(forKey: "is_favourite") as! Bool

    }
    
    var id:String
    var name:String
    var url:String
    var categories:[category]
    var review_count:Int
    var rating:Double
    
    //need to create location model
    var location:location
    
    var phone:String
    var display_phone:String
    var distance:Double
    var price:String?
    
    var transactions:[String]?
    
    //this variable will keep track if the model is a favourite or not
    var is_favourite:Bool = false
    
    init(id:String,name:String,url:String,review_count:Int,rating:Double,phone:String,display_phone:String,distance:Double,price:String?,categories:[category],location:location,transactions:[String]?) {
        
        self.id = id
        self.name = name
        self.url = url
        self.review_count = review_count
        self.rating = rating
        self.phone = phone
        self.display_phone = display_phone
        self.distance = distance
        self.price = price
        self.categories = categories
        self.location = location
        self.transactions = transactions
    }
    
}
