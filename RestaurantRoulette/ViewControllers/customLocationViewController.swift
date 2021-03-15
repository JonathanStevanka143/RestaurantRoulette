//
//  customLocationViewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import UIKit
import Foundation
import MapKit

class customLocationViewController: UIViewController {
    
    //map
    @IBOutlet var customLocationMap: MKMapView!
    
    //button
    @IBOutlet var selectMapLocation: UIButton!
    
    //this var will hold the center of the map coord
    var centerMapCoord:CLLocationCoordinate2D!
    //this will hold the filter options saved on the phone
    var filterOptions:FilterSettings!
    //this array of categories is what the user currently wants to search nearby with
    var categories:[Categories]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    //MARK: SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        
        case "customLocationToRestaraunts":
            
            if let destinationVC = segue.destination as? restaurantsListTableviewController {
                
                //set the centermapcoord on the receiving VC
                destinationVC.centerMapCoord = customLocationMap.centerCoordinate
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
    @IBAction func selectMapLocationClicked(_ sender: Any) {
        print("mapCenterCoord:",customLocationMap.centerCoordinate)
    }
    
    
    
}
