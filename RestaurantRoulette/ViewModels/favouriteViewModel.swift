//
//  favouriteViewModel.swift
//  Roulette
//
//  Created by Mac User on 2021-04-22.
//

import Foundation
import UIKit
import CoreData

class favouriteViewModel {
    //this will allow viewcontrollers to set their own delegate to get relative information back
    weak var delegate: favouriteViewModelDelegate?
    //per apple documentation
    var container: NSPersistentContainer! {
        //this allows it to work on all IOS levels supported
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    func grabFavourites(){
        
        //create a model context
        let moc = container.viewContext
        
        //create a fetched results controller
        var fetchedResultsController: NSFetchedResultsController<FavouriteRestaurant>?
        
        //prepare the request for the local data
        let request = NSFetchRequest<FavouriteRestaurant>(entityName: "FavouriteRestaurant")
        
        //set a sort descriptor for how we retreive the keys
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest:
                                                                            request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.isEmpty == false {
                
                //return this through the delegate that way any VC that has the VM associated as a Delegate will receive the data
                self.delegate?.returnAllFavourites(favouriteRestaurants: fetchedResultsController?.fetchedObjects)
                
            }else {
                //do nothing
//                print("objects:",fetchedResultsController?.fetchedObjects?.count)
            }
        }catch {
            print("fetch request failed")
        }
        
    }
    
    //MARK: below functions are used for saving a fav restaurant
    //this function will save the restaurant
    func saveRestaurant(restaurant:restaurant){
        
        //create a model context
        let moc = container.viewContext
        
        //create a fetched results controller
        var fetchedResultsController: NSFetchedResultsController<FavouriteRestaurant>?
        
        //prepare the request for the local data
        let request = NSFetchRequest<FavouriteRestaurant>(entityName: "FavouriteRestaurant")
        
        //set a sort descriptor for how we retreive the keys
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest:
                                                                            request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.isEmpty == false {
                //GOAL: create the first saved object
                //create a variable to indicate if the item exists or not
                var already_exists:Bool = false
                //create a loop to check if there is an item that has the same id
                for favRest in (fetchedResultsController?.fetchedObjects)! {
                    
                    if favRest.id == restaurant.id {
                        already_exists = true
                        break
                    }
                }
                
                if already_exists == false {
                    //create the favRest
                    createFavRestaurant(moc: moc, restaurant: restaurant)
                }else{
                    //do nothing
                    
                    
                }
                
                
            }else{
                //create first favourite!!!!
                //create the favRest
                createFavRestaurant(moc: moc, restaurant: restaurant)
            }
            
            
            
        }catch {
            print("fetch request failed")
        }
        
    }
    
    func createFavRestaurant(moc:NSManagedObjectContext,restaurant:restaurant){
        let favouriteRestaurant = FavouriteRestaurant(context: moc)
        favouriteRestaurant.id = restaurant.id
        favouriteRestaurant.name = restaurant.name
        favouriteRestaurant.url = restaurant.url
        favouriteRestaurant.reviewCount = Int64(restaurant.review_count)
        favouriteRestaurant.rating = restaurant.rating
        favouriteRestaurant.location = restaurant.location
        favouriteRestaurant.phone = restaurant.phone
        favouriteRestaurant.displayPhone = restaurant.display_phone
        favouriteRestaurant.price = restaurant.price
        
        //create a new mutable array
        let catArray = NSMutableArray()
        for cat in restaurant.categories {
            catArray.add(["title":cat.title])
        }
        favouriteRestaurant.categories = catArray

        //create a mutable array to store the transactions
        let transactionArray = NSMutableArray()
        for transaction in restaurant.transactions {
            if transaction == "delivery" {
                transactionArray.add(["delivery"])
            }
            if transaction == "pickup" {
                transactionArray.add(["pickup"])
            }
            print("tt:",transaction)
            
        }
        //print("trans:",transactionArray)
        favouriteRestaurant.transactions = transactionArray
        //save the context
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
    }
    
}

protocol favouriteViewModelDelegate: class {
    
    func returnAllFavourites(favouriteRestaurants:[FavouriteRestaurant]?)
    
}
