//
//  ViewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-13.
//

import UIKit
import MapKit
import CoreData
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet var currentLocationMapView: MKMapView!
    @IBOutlet var customLocationMapView: MKMapView!
    
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var customLocationButton: UIButton!
    
    //per apple documentation
    var container: NSPersistentContainer!
    
    //this will hold the filter options saved on the phone
    var filterOptions:FilterSettings!
    var categories:[Categories]!
    
    //hook up the view model(where updates will be made etc)
    var ViewModel = tabVC1ViewModel()
    
    //create a connection to the locationmanager
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    //create a variable to hold the centermap data for when a button gets clicked
    var centerMapCoord: CLLocationCoordinate2D!
    
    //this value will represent if the app has been opened more than once
    var isFirstTimeOpening:Bool! = true
    
    override func viewWillAppear(_ animated: Bool) {
        //updated the top current location map everytime the app has been opened except for the first time since closing using the boolean value
        if isFirstTimeOpening == false {
            DispatchQueue.global().async {
                //check to see if the location services are enabled
                if CLLocationManager.locationServicesEnabled() {
                    
                    //start updating the users location
                    self.locationManager.startUpdatingLocation()
                    
                    //grab the filter results incase the user has updated them this keeps the user settings updated at all times
                    self.ViewModel.getFilterResults()
                    self.ViewModel.getCategoryData()
                    
                }else {
                    //location services not enabled do something here
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the color of the navbar back button
        self.navigationController?.navigationBar.tintColor = UIColor.init(named: "primaryColor")
        
        //setup button label shadows here etc
        currentLocationButton.layer.shadowRadius = 10.0
        currentLocationButton.layer.shadowOpacity = 1
        customLocationButton.layer.shadowRadius = 10.0
        customLocationButton.layer.shadowOpacity = 1
        
        //request usage for location services
        //instantiate a new locationmanager
        locationManager = CLLocationManager()
        //set the delegate of the LM manager to self
        locationManager.delegate = self
        //ask for permission from the user to display the map
        locationManager.requestWhenInUseAuthorization()
        //check to see if the location services are enabled
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                //ask to use while in use
                self.locationManager.requestWhenInUseAuthorization()
                //set the distance property where the app should update the location
                self.locationManager.distanceFilter = 10
                //start updating the location
                self.locationManager.startUpdatingLocation()
                //set the accuracy
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                //set pauses location updates to false
                self.locationManager.pausesLocationUpdatesAutomatically = false
                
            }else {
                //location services not enabled do something here
                
            }
        }
        //set the container, for some reason this would not work in the scenedelegate(ios 14^)
        //this allows it to work on all IOS levels supported
        container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        
        //set the NSPersistentContainer on the view model per MVVM
        ViewModel.container = container
        
        //set the delegate for the ViewModel
        ViewModel.delegate = self
        
        //IMPORTANT FOR APP TO RUN
        //MARK:GET FILTER RESULTS
        //this allows us to grab the coredata save results for the user
        ViewModel.getFilterResults()
        
        //MARK:GET CATEGORY RESULTS
        ViewModel.getCategoryData()
        
        //set the isfirsttimeviewing variable to false to update the map everytime the user opens the app
        isFirstTimeOpening = false
        
        //prompt the user to rate the app on the store, this should in turn get more users onto the app!
        // If the app doesn't store the count, this returns 0.
        var count = UserDefaults.standard.integer(forKey: "RatingsCount")
        count += 1
        UserDefaults.standard.set(count, forKey: "RatingsCount")
        print("Process completed \(count) time(s).")

        // Keep track of the most recent app version that prompts the user for a review.
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "AppVersion")

        // Get the current bundle version for the app.
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary.") }
         // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
         if count >= 2 && currentVersion != lastVersionPromptedForReview {
             Task { @MainActor [weak self] in
                 // Delay for two seconds to avoid interrupting the person using the app.
                 // Use the equation n * 10^9 to convert seconds to nanoseconds.
                 try? await Task.sleep(nanoseconds: UInt64(2e9))
                 if let windowScene = self?.view.window?.windowScene,
                    self?.navigationController?.topViewController is ViewController {
                     SKStoreReviewController.requestReview(in: windowScene)
                     UserDefaults.standard.set(currentVersion, forKey: "AppVersion")
                 }
             }
         }
        
        
        
    }
    
    //prepare function will allow us to send data to any screens we want
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        
        //filtersettingsViewController
        case "filterScreenSegue":
            if let destinationVC = segue.destination as? filterSettingsViewController {
                
                //set the container on the filter screen
                destinationVC.container = container
                //set the settings on the filter screen
                destinationVC.filterOptions = filterOptions
                //set the categories on the filter screen
                destinationVC.categories = categories
            }
            
            break
            
        //currentLocationViewController
        case "currentLocationSegue":
            
            if let destinationVC = segue.destination as? restaurantsListTableviewController {
                //set the centermapcoord on the receiving VC
                destinationVC.centerMapCoord = centerMapCoord
                //set the filteroptions
                destinationVC.filterOptions = filterOptions
                //set the categories
                destinationVC.categories = categories
            }
            
            
            break
            
        //customLocationViewController
        case "CustomlocationSegue":
            
            if let destinationVC = segue.destination as? customLocationViewController {
                //set the filteroptions
                destinationVC.filterOptions = filterOptions
                //set the categories
                destinationVC.categories = categories
            }
            
            break
        default:
            
            break
            
        }
        
    }
    
    //MARK: BUTTON ACTIONS
    
    @IBAction func didTapOnCurrentLocationButton(_ sender: Any) {
        
        //set the centerMapCoord to be that of the current location map
        centerMapCoord = currentLocationMapView.centerCoordinate
        
    }
    
}


//this will take all the data back from the viewmodel delegate
extension ViewController:tabVC1ViewControllerDelegate {
    
    func getFilterOptionsBack(currentFilterOptions: FilterSettings?) {
        //        print(currentFilterOptions)
        
        //1. check and make sure that the filter options is not null
        if currentFilterOptions != nil {
            //2. set the filter options on the global filtersettings
            filterOptions = currentFilterOptions
        }
        
    }
    
    func getCategoryDataBack(currentCategories: [Categories]?) {
        
        //1. check if the currentCategories is not empty
        if currentCategories?.isEmpty == false {
            //set the categories top level so they can be utilized in as search results
            categories = currentCategories
            
        }else {
            
        }
    }
    
}

//MARK: LOCATION DELEGATE
extension ViewController: CLLocationManagerDelegate {
    
    //extend the function so that we can receive updates on where the user is currently
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.last != nil {
            currentLocation = locations.last
        }
        
        if currentLocation != nil {
            
//            print("------")
//            print(currentLocation)
            
            // Zoom to user location
            let viewRegion = MKCoordinateRegion(center: currentLocation!.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            currentLocationMapView.setRegion(viewRegion, animated: false)
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}




