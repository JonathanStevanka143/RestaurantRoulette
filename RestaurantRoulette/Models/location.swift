//
//  location.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-23.
//

import Foundation

class location: NSObject,NSSecureCoding,NSCoding {
    static var supportsSecureCoding: Bool = true
    
    
    enum Keys: String {
      
        case address1 = "Address1"
        case address2 = "Address2"
        case address3 = "Address3"
        case country = "Country"
        case city = "City"
        case zip_code = "Zip_code"
        case state = "State"
        case display_address = "Display_address"
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(address1, forKey: Keys.address1.rawValue)
        coder.encode(address2, forKey: Keys.address2.rawValue)
        coder.encode(address3, forKey: Keys.address3.rawValue)
        coder.encode(country, forKey: Keys.country.rawValue)
        coder.encode(city, forKey: Keys.city.rawValue)
        coder.encode(zip_code, forKey: Keys.zip_code.rawValue)
        coder.encode(state, forKey: Keys.state.rawValue)
        coder.encode(display_address, forKey: Keys.display_address.rawValue)
    }
    
    required init?(coder: NSCoder) {
        self.address1 = coder.decodeObject(forKey: Keys.address1.rawValue) as? String ?? ""
        self.address2 = coder.decodeObject(forKey: Keys.address2.rawValue) as? String ?? ""
        self.address3 = coder.decodeObject(forKey: Keys.address3.rawValue) as? String ?? ""
        self.country = coder.decodeObject(forKey: Keys.country.rawValue) as? String ?? ""
        self.city = coder.decodeObject(forKey: Keys.city.rawValue) as? String ?? ""
        self.zip_code = coder.decodeObject(forKey: Keys.zip_code.rawValue) as? String ?? ""
        self.state = coder.decodeObject(forKey: Keys.state.rawValue) as? String ?? ""
        self.display_address = coder.decodeObject(forKey: Keys.display_address.rawValue) as? [String] ?? [""]
    }
    
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
