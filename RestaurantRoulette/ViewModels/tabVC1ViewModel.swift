//
//  tabVC1ViewModel.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-13.
//

import CoreData

class tabVC1ViewModel {
    
    //this will allow viewcontrollers to set their own delegate to get relative information back
    weak var delegate: tabVC1ViewControllerDelegate?
    //per apple documentation
    var container: NSPersistentContainer!
    //create a fetched results controller
    var fetchedResultsController: NSFetchedResultsController<FilterSettings>?
    
    
    //this will allow us to get the current filter settings from the viewcontroller
    func getFilterResults(){
        
        let moc = container.viewContext
        //prepare the request for the local data
        let request = NSFetchRequest<FilterSettings>(entityName: "FilterSettings")
        
        //set a sort descriptor for how we retreive the keys
        request.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest:
                                                                            request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.isEmpty == false {
                
                delegate?.getFilterOptionsBack(currentFilterOptions: fetchedResultsController?.fetchedObjects?.first)
                
            }else {
                //do nothing as we dont need to set up the default keys
            }
        }catch {
            print("fetch request failed")
        }
        
    }
    
    func getCategoryData(){
        
        let moc = container.viewContext
        
        //create a fetched results controller
        var fetchedCategoriesController: NSFetchedResultsController<Categories>?
        
        //prepare the request for the local data
        let request = NSFetchRequest<Categories>(entityName: "Categories")
        
        //set a sort descriptor for how we retreive the keys
        request.sortDescriptors = [NSSortDescriptor(key: "categoryTitle", ascending: true)]
        
        //
        fetchedCategoriesController = NSFetchedResultsController(fetchRequest:
                                                                            request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedCategoriesController?.performFetch()
            
            if fetchedCategoriesController?.fetchedObjects?.isEmpty == false {
                
                delegate?.getCategoryDataBack(currentCategories: fetchedCategoriesController?.fetchedObjects)
                
            }else {
                //do nothing as we dont need to set up the default keys
            }
        }catch {
            print("fetch request failed")
        }
        
    }
    
    
}

//this protocol will hold the functions for the viewcontroller
protocol tabVC1ViewControllerDelegate: class {
    
    //this will allow the current viewcontroller to get data back to the controller
    func getFilterOptionsBack(currentFilterOptions:FilterSettings?)
    
    //this function will allow us to send back the array of categories back to the user
    func getCategoryDataBack(currentCategories:[Categories]?)
    
}
