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
    
    //tags collectionview for food categories
    @IBOutlet var tagsCollectionView: UICollectionView!
    
    
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
    //this will hold the categories clicked by the user
    var clickedOnCategories:[Categories]! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the tags collection view as the delegate and datasource
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        
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
                
        //set the persistent container on the viewmodel
        viewModel.container = container
        //set the viewmodel delegate to receive information from the view model back
        viewModel.delegate = self
        
        print("t",tagsCollectionView.collectionViewLayout.collectionViewContentSize)
        
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

extension filterSettingsViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cellForTag = collectionView.dequeueReusableCell(withReuseIdentifier: "tagsCollectionViewCell", for: indexPath) as! TagCVcell
        
        //grab the current category being represented
        let currentCategory = categories[indexPath.row]
        
        //set the outline view for the border so that it shows them it has yet to be selected
        cellForTag.tagOutlineView.layer.cornerRadius = 10
        cellForTag.tagOutlineView.layer.borderWidth = 1
        cellForTag.tagOutlineView.layer.borderColor = UIColor.init(red: 1.0, green: 0.54, blue: 0.59, alpha: 1.0).cgColor
        
        if currentCategory.isCategoryChecked == true {
            //if the cell is checked then we remove the background and set the outline instead
            cellForTag.tagOutlineView.backgroundColor = UIColor.init(red: 1.0, green: 0.54, blue: 0.59, alpha: 1.0)
            
        }else {
            //if the cell is not checked then when we click on it we change the background color
            cellForTag.tagOutlineView.backgroundColor = nil
            
        }
        
        
        //set the label of the category it is representing
        cellForTag.categoryLabel.text = categories[indexPath.row].categoryTitle
        
        return cellForTag
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //grab the current cell based on indexpath
        let currentCell = collectionView.cellForItem(at: indexPath) as! TagCVcell
        //grab the current category being represented
        let currentCategory = categories[indexPath.row]
        
        //check if the category is selected already, this will allow us to set the cell based on local data
        //TRUE - means the category is selected
        //FALSE - means the category is not selected
        if currentCategory.isCategoryChecked == true {
            //set the iscategorychecked to be false
            currentCategory.isCategoryChecked = false
            //if the cell is checked then we remove the background and set the outline instead
            currentCell.tagOutlineView.backgroundColor = nil
            
            if clickedOnCategories.isEmpty == false {
                //remove the category from the array if it exists
                if clickedOnCategories.contains(currentCategory){
                    clickedOnCategories.remove(at: clickedOnCategories.firstIndex(of: currentCategory)!)
                    
                }
            }
            
        }else {
            //set the iscategorychecked to be true
            currentCategory.isCategoryChecked = true
            //if the cell is not checked then when we click on it we change the background color
            currentCell.tagOutlineView.backgroundColor = UIColor.init(red: 1.0, green: 0.54, blue: 0.59, alpha: 1.0)
            
            //add this newly selected cell into our array
            clickedOnCategories.append(currentCategory)
            
        }
        
    }
    
}
