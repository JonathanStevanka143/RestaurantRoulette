//
//  filterSettingsViewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-16.
//

import UIKit
import CoreData

class filterSettingsViewController: UIViewController {
    
    //uiViews
    @IBOutlet var priceRangesUIVIEW: UIView!
    @IBOutlet var distanceUIVIEW: UIView!
    
    //buttons
    @IBOutlet var saveButton: UIButton!
    
    //price range controls
    @IBOutlet var priceRangeGreateOrLessThanControl: UISegmentedControl!
    @IBOutlet var priceRangeValueControl: UISegmentedControl!
    
    //distance
    @IBOutlet var totalDistanceTextField: UITextField!
    @IBOutlet var distanceMeasurementControl: UISegmentedControl!
    @IBOutlet var distanceMeasurementSlider: UISlider!
    
    
    //per apple documentation
    //this is set in segue in viewcontroller
    //gives us access to core data stack
    var container: NSPersistentContainer!
    
    //grab the relative viewmodel to this controller
    var viewModel = filterSettingsViewModel()
    
    //this holds the current filteroptions that were loaded from the device
    var filterOptions:FilterSettings!
    //categories loaded from device
    var categories:[Categories]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //set the UIviews to have the same data as on the phone
        //1. check if the filteroptions is not nil
        //2. set the 'below price | above price
        //3. set the price range selected
        //4. set the distance fields
        if filterOptions != nil {
            //2
            if filterOptions.isBelowPriceRange == true {
                priceRangeGreateOrLessThanControl.selectedSegmentIndex = 0
            }else {
                priceRangeGreateOrLessThanControl.selectedSegmentIndex = 1
            }
            
            //3
            priceRangeValueControl.selectedSegmentIndex = Int(filterOptions.priceRangeLevel - 1)
            
            //4
            if filterOptions.isDistanceInKM == true {
                
                distanceMeasurementControl.selectedSegmentIndex = 0
                totalDistanceTextField.text = "\(filterOptions.distance) km"
                distanceMeasurementSlider.value = Float(filterOptions.distance)
                
            }else {
                
                distanceMeasurementControl.selectedSegmentIndex = 1
                totalDistanceTextField.text = "\(filterOptions.distance) miles"
                distanceMeasurementSlider.value = Float(filterOptions.distance)

            }
        }
        
        print(categories)
        
        //set the persistent container on the viewmodel
        viewModel.container = container
        //set the viewmodel delegate to receive information from the view model back
        viewModel.delegate = self
    }
    
    
    //MARK: PRICE RANGES ACTIONS
    @IBAction func priceRangesGreaterOrBelowValueChanged(_ sender: Any) {
        
        if priceRangeGreateOrLessThanControl.selectedSegmentIndex == 0 {
            
            
            
        }else if priceRangeGreateOrLessThanControl.selectedSegmentIndex == 1 {
            
            
        }
        
    }
    //MARK: DISTANCE ACTIONS
    @IBAction func distanceMeasurementControlChanged(_ sender: Any) {
        
        let distanceInInt = Int(distanceMeasurementSlider.value.rounded())
        
        //check what distance measurement it is
        //0 = km
        //1 = miles
        if distanceMeasurementControl.selectedSegmentIndex == 0 {
            
            totalDistanceTextField.text = "\(distanceInInt) km"
            
        }else if distanceMeasurementControl.selectedSegmentIndex == 1 {
            
            totalDistanceTextField.text = "\(distanceInInt) miles"
            
        }
    }
    
    
    @IBAction func distanceValueSliderChanged(_ sender: Any) {
        
        let distanceInInt = Int(distanceMeasurementSlider.value.rounded())
        
        //check what distance measurement it is
        //0 = km
        //1 = miles
        if distanceMeasurementControl.selectedSegmentIndex == 0 {
            
            totalDistanceTextField.text = "\(distanceInInt) km"
            
        }else if distanceMeasurementControl.selectedSegmentIndex == 1 {
            
            totalDistanceTextField.text = "\(distanceInInt) miles"
            
        }
        
    }
    
    //MARK: BUTTON ACTIONS
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        //1. set the 'isBelowOrAbovePrice' controls
        //2. set the 'price level'
        //3. set the 'distance'
        //4. set the 'isDistanceInKm' control for distance
        
        var isBelowOrAbovePrice:Bool = filterOptions.isBelowPriceRange
        var priceLevel:Int = Int(filterOptions.priceRangeLevel)
        var distance:Int = Int(filterOptions.distance)
        var isDistanceInKm:Bool = filterOptions.isDistanceInKM
        
        
        //1. set the price range based on the current selected options
        if priceRangeGreateOrLessThanControl.selectedSegmentIndex == 0 {
            isBelowOrAbovePrice = true
        }else if priceRangeGreateOrLessThanControl.selectedSegmentIndex == 1 {
            isBelowOrAbovePrice = false
        }
        
        //2. set the priceLevel based on the currently selected
        if priceRangeValueControl.selectedSegmentIndex == 0{
            priceLevel = 1
        }else if priceRangeValueControl.selectedSegmentIndex == 1 {
            priceLevel = 2
        }else if priceRangeValueControl.selectedSegmentIndex == 2 {
            priceLevel = 3
        }else if priceRangeValueControl.selectedSegmentIndex == 3 {
            priceLevel = 4
        }
        
        //3. set the distance based on the currently selected slider option
        distance = Int(distanceMeasurementSlider.value.rounded())
        
        //4. set the isdistanceinKM boolean
        if distanceMeasurementControl.selectedSegmentIndex == 0 {
            isDistanceInKm = true
        }else if distanceMeasurementControl.selectedSegmentIndex == 1 {
            isDistanceInKm = false
        }
        
        //call the viewmodel function to save the data
        viewModel.saveResultsFromButton(isBelowOrAbovePrice: isBelowOrAbovePrice, priceLevel: priceLevel, distance: distance, isDistanceInKm: isDistanceInKm)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}

extension filterSettingsViewController:filterSettingsViewModelDelegate{
    
    func getSaveResultsFromButtonBack(didSave: Bool) {
        print(didSave)
    }
    
}
