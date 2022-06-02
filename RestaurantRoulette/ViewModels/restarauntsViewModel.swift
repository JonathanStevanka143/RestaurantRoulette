//
//  restarauntsViewModel.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData
import MapKit

class restarauntsViewModel {
    //this will allow viewcontrollers to set their own delegate to get relative information back
    weak var delegate: restarauntsViewModelDelegate?
    //per apple documentation
    var container: NSPersistentContainer!
    //init our api network class that way we can utilize its methods
    var apiNetwork = restarauntAPINetwork()
    //this function will find all of the close restaraunts in the vicinity by using the user filterOptions
    func getCloseRestaraunts(location:CLLocation, country:String?,address:String,options:FilterSettings,categories:[Categories]){
        
        //create a string to hold the price level(s)
        var priceRange:String!
        
        //check if the pricerange is below or above
        if options.isBelowPriceRange == true {
            
            //if the number selected is 4, the string would contain (1,2,3,4)
            if options.priceRangeLevel == 1 {
                priceRange = "1"
            }else if options.priceRangeLevel == 2 {
                priceRange = "1,2"
            }else if options.priceRangeLevel == 3 {
                priceRange = "1,2,3"
            }else if options.priceRangeLevel == 4 {
                priceRange = "1,2,3,4"
            }
            
        }else {
            
            //if the number selected is 4, the string would contain (4)
            if options.priceRangeLevel == 1 {
                priceRange = "1,2,3,4"
            }else if options.priceRangeLevel == 2 {
                priceRange = "2,3,4"
            }else if options.priceRangeLevel == 3 {
                priceRange = "3,4"
            }else if options.priceRangeLevel == 4 {
                priceRange = "4"
            }
            
        }
        
//        print(priceRange)
        
        
        //create a variable to conver the distance option
        var distanceMeteres:Int!
        
        //check if the distance is in KM or not and do the conversion
        if options.isDistanceInKM == true {
            //setting the meteres based on KM's
            distanceMeteres = Int(options.distance * 1000)
        }else {
            //setting the meteres based on MILES
            distanceMeteres = Int(options.distance * 1609)
            //check to see if the distance is greater than 40,000. if it is set it to 40,000
            if distanceMeteres > 40000 {
                distanceMeteres = 40000
            }
        }
                
        
        //create a list of selected categories the user wants to use
        var optionString = ""
        for i in categories {
            
            if i.isCategoryChecked == true {
                optionString += "\(i.categoryAlias!),"
            }
            
        }
        
        //remove the last "," from the string
        optionString.popLast()
//        print(optionString)
        
        
        apiNetwork.getCloseRestaraunts(location: location ,isUsingLocalOnly: true ,country: country ,priceLevel: priceRange,address: address , radius: "\(distanceMeteres ?? 5000)", categories: optionString) { restaurants in
            
            //call the delegate so the viewcontroller can get restaraunts back
            self.delegate?.returnCloseRestaraunts(closeRestaraunts: restaurants)
        }
        
    }
    
}

//this protocol will hold the functions for the viewcontroller
protocol restarauntsViewModelDelegate: class {
    
    //this function will return the list of restaraunts
    func returnCloseRestaraunts(closeRestaraunts:[restaurant]?)
    
}
