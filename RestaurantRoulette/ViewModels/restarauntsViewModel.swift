//
//  restarauntsViewModel.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData

class restarauntsViewModel {
    //this will allow viewcontrollers to set their own delegate to get relative information back
    weak var delegate: restarauntsViewModelDelegate?
    //per apple documentation
    var container: NSPersistentContainer!
    
    var apiNetwork = restarauntAPINetwork()

    
    //this function will find all of the close restaraunts in the vicinity by using the user filterOptions
    func getCloseRestaraunts(address:String,options:FilterSettings,categories:[Categories]){
        
        //left off here
//        print(options)
        
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
        
        
        apiNetwork.getCloseRestaraunts(address: address , radius: "\(distanceMeteres ?? 5000)", categories: optionString) { restaurants in
            
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
