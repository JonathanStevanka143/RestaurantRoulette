//
//  category.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-23.
//

import Foundation
import UIKit
import CoreData

class category: NSObject,Codable {
    
    var alias:String
    var title:String
    
    init(alias:String,title:String) {
        self.alias = alias
        self.title = title
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(alias, forKey: alias)
        coder.encode(title, forKey: title)
    }
    
}
