//
//  ViewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-13.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var currentLocationMapView: MKMapView!
    @IBOutlet var customLocationMapView: MKMapView!
    
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var customLocationButton: UIButton!
    
    //per apple documentation
    var container: NSPersistentContainer!
    
    //hook up the view model(where updates will be made etc)
    var ViewModel = tabVC1ViewModel()
        
    //create a connection to the locationmanager
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        //set the desired accuracy of the location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //ask for permission from the user to display the map
        locationManager.requestWhenInUseAuthorization()
        //grab the current authorization status for this permission
        let authStatus = CLLocationManager.authorizationStatus()
        
        //check to see if the location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            //ask to use while in use
            locationManager.requestWhenInUseAuthorization()
            //start updating the location
            locationManager.startUpdatingLocation()
        }else {
            //location services not enabled do something here
            
            
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
        
    }

    @IBAction func didTapOnCurrentLocationButton(_ sender: Any) {
        
        //send the data towards the view model
//        ViewModel.testButtonPress(from: "print here hahaha")
        
    }

}


//MARK: LOCATION DELEGATE
extension ViewController: CLLocationManagerDelegate {
    
    //extend the function so that we can receive updates on where the user is currently
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
                currentLocationMapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    
}


//this will take all the data back from the viewmodel delegate
extension ViewController:tabVC1ViewControllerDelegate {

    func getFilterOptionsBack(currentFilterOptions: FilterSettings?) {
        print(currentFilterOptions)
    }
}

