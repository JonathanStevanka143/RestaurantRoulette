//
//  location.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-23.
//

import Foundation

class location: NSObject,Codable {
    
    var address1:String
    var address2:String
    var address3:String
    var country:String
    var city:String
    var zip_code:String
    var state:String
    var display_address:[String]
    
    init(address1:String,address2:String,address3:String,country:String,city:String,zip_code:String,state:String,display_address:[String]) {
        self.address1 = address1
        self.address2 = address2
        self.address3 = address3
        self.country = country
        self.city = city
        self.zip_code = zip_code
        self.state = state
        self.display_address = display_address
    }
    
}
