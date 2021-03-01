//
//  filterSettingsViewModel.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-16.
//

import Foundation
import UIKit
import CoreData

class filterSettingsViewModel {
    //this will allow viewcontrollers to set their own delegate to get relative information back
    weak var delegate: filterSettingsViewModelDelegate?
    //per apple documentation
    var container: NSPersistentContainer!
    
    //this will save the results from the main page
    func saveResultsFromButton(isBelowOrAbovePrice:Bool,priceLevel:Int,distance:Int,isDistanceInKm:Bool){
        
        //create a model context
        let moc = container.viewContext
        
        //create a fetched results controller
        var fetchedResultsController: NSFetchedResultsController<FilterSettings>?
        
        //prepare the request for the local data
        let request = NSFetchRequest<FilterSettings>(entityName: "FilterSettings")
        
        //set a sort descriptor for how we retreive the keys
        request.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: false)]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest:
                                                                            request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.isEmpty == false {
                
                let filterSettings:FilterSettings! = fetchedResultsController?.fetchedObjects?.first
                filterSettings.isBelowPriceRange = isBelowOrAbovePrice
                filterSettings.priceRangeLevel = Int64(priceLevel)
                filterSettings.distance = Int64(distance)
                filterSettings.isDistanceInKM = isDistanceInKm
                
                //save the currentContext so that our changes are persisteddx
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                
            }else {
                //do nothing as we dont need to set up the default keys
            }
        }catch {
            print("fetch request failed")
        }
        

    }
    
}

//this protocol will hold the functions for the viewcontroller
protocol filterSettingsViewModelDelegate: class {
    
    func getSaveResultsFromButtonBack(didSave:Bool)
    
}
