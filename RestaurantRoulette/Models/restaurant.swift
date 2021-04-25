//
//  restaurant.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData

class restaurant: NSObject,Codable {
    
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
    var price:String
    
    var transactions:[String]
    
    //this variable will keep track if the model is a favourite or not
    var is_favourite:Bool = false
    
    init(id:String,name:String,url:String,review_count:Int,rating:Double,phone:String,display_phone:String,distance:Double,price:String,categories:[category],location:location,transactions:[String]) {
        
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
