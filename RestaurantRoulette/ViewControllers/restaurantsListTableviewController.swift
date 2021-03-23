//
//  restarauntsListTableviewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData
import MapKit
import CoreLocation

class restaurantsListTableviewController: UIViewController {
    
    //FIRST PHASE OUTLETS
    //nav bar items
    @IBOutlet var editButton: UIButton!
    //views
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    @IBOutlet var searchingLabel: UILabel!
    
    @IBOutlet var tableViewHolder: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewTintOverlayView: UIView!
    @IBOutlet var restaurantSelectedView: UIView!
    
    /**
     OUTLETS/LABELS/BUTTONS FOR THE SELECTED RESTARAUNT
     */
    @IBOutlet var restaurantSelectedMapView: MKMapView!
    @IBOutlet var restaurantSelectedTitle: UILabel!
    @IBOutlet var restaurantSelectedDistance: UILabel!
    @IBOutlet var restaurantSelectedReviews: UILabel!
    @IBOutlet var restaurantSelectedTags: UILabel!
    @IBOutlet var restaurantSelectedPricerange: UILabel!
    @IBOutlet var restaurantSelectedPickupImage: UIImageView!
    @IBOutlet var restaurantSelectedDeliveryImage: UIImageView!
    @IBOutlet var restaurantSelectedPhonenumber: UILabel!
    
    @IBOutlet var restaurantSelectedFavview1: UIView!
    @IBOutlet var restaurantSelectedFavView1HalfView: UIView!
    @IBOutlet var restaurantSelectedFavview2: UIView!
    @IBOutlet var restaurantSelectedFavView2HalfView: UIView!
    @IBOutlet var restaurantSelectedFavview3: UIView!
    @IBOutlet var restaurantSelectedFavView3HalfView: UIView!
    @IBOutlet var restaurantSelectedFavview4: UIView!
    @IBOutlet var restaurantSelectedFavView4HalfView: UIView!
    @IBOutlet var restaurantSelectedFavview5: UIView!
    @IBOutlet var restaurantSelectedFavView5HalfView: UIView!
    
    @IBOutlet var callCircleView: UIView!
    @IBOutlet var callButton: UIButton!
    
    @IBOutlet var directionsCircleView: UIView!
    @IBOutlet var directionsButton: UIButton!
    
    @IBOutlet var moreInfoCircleView: UIView!
    @IBOutlet var infoButton: UIButton!
    
    //buttons
    @IBOutlet var continueButton: UIButton!
    
    //FIRST PHASE VARIABLES
    //this holds the map coords that the user wanted to use
    var centerMapCoord: CLLocationCoordinate2D!
    //filter options from the phone, set by the sending VC
    var filterOptions:FilterSettings!
    //this array of categories is what the user currently wants to search nearby with
    var categories:[Categories]!
    //hook up the view model(where updates will be made etc)
    var ViewModel = restarauntsViewModel()
    //this will hold all of the tableview data
    var restaurants:[restaurant]! = []
    
    //SECOND PHASE VARIABLES
    //this holds the currently selected cell number
    var currentlySelectedCell:IndexPath! = nil
    
    
    override func viewDidLoad() {
        
        ViewModel.delegate = self
        
        //1.create a function to reverse geocode an address and pass it to the API for more accurate results
        geocodeLocation(lat: centerMapCoord.latitude, long: centerMapCoord.longitude)
        
        
        //set the tableview delegate
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //set the alpha on the restaraunt overview to be "hidden"
        restaurantSelectedView.alpha = 0
        //set the border radius on the selected view
        restaurantSelectedView.layer.cornerRadius = 10
        //set the border color and the width for the three selected restaurant buttons
        //callview setup
        callCircleView.layer.cornerRadius = 30
        callCircleView.layer.borderWidth = 1
        callCircleView.layer.borderColor = UIColor.red.cgColor
        //directionview setup
        directionsCircleView.layer.cornerRadius = 30
        directionsCircleView.layer.borderWidth = 1
        directionsCircleView.layer.borderColor = UIColor.red.cgColor
        //infoview setup
        moreInfoCircleView.layer.cornerRadius = 30
        moreInfoCircleView.layer.borderWidth = 1
        moreInfoCircleView.layer.borderColor = UIColor.red.cgColor
    }
    
    
    //MARK: BUTTON ACTIONS
    @IBAction func editButtonPressed(_ sender: Any) {
        //check to see if the table is in editing mode or not
        if tableView.isEditing == false{
            //begin the editing
            tableView.isEditing = true
            //set the text on the button to 'done'
            editButton.setTitle("Done", for: .normal)
        }else {
            //end the editing
            tableView.isEditing = false
            //set the text on the button back to 'edit'
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    var phonenumberForCall:String!
    @IBAction func callButtonPressed(_ sender: Any) {
                
        //scrub the phone number first to make it "callable"
        phonenumberForCall.removeAll{$0 == "-"}
        phonenumberForCall.removeAll{$0 == "("}
        phonenumberForCall.removeAll{$0 == ")"}
        phonenumberForCall.removeAll{$0 == " "}
        
        let url = URL(string: "tel://" + phonenumberForCall)
        
        if UIApplication.shared.canOpenURL(url!) == true {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        
    }
    
    //create a string that will hold the address
    var directionsForMap:MKMapItem!
    @IBAction func directionButtonPressed(_ sender: Any) {
        
        directionsForMap.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    @IBAction func moreInfoButtonPressed(_ sender: Any) {
        
        
    }
    
    
    
    //this variable represents the phase of which the tableview is in
    //phase1: the user can edit and remove items off the list, scrollview is still scrollable
    //phase2: the 'game' has now begun the user has to click the spin button and the tableview will automatically begin the animation down, the data is also shuffled
    var phase2:Bool! = false
    //this represents if the tableview has been spun yet, this will allow us to reset the layout if need be
    var hasSpun:Bool! = false
    @IBAction func spinTheWheelButtonPressed(_ sender: Any) {
        //set the button to be inactive
        continueButton.isEnabled = false
        
        //if phase2 is set changed the UI accordingly
        if phase2 == true {
            //1.disable scrolling
            //2.set the button to say "remove & spin"
            continueButton.setTitle("Remove & Spin", for: .normal)
            
            //if the table has been spun and a restauraunt has been selected, remove it
            if hasSpun == true {
                
                //remove the restaraunt from the list so it cant be used again
                let removeThis = restaurants[currentlySelectedCell.row]
                
                //remove all copies of the model in the tableview data array
                restaurants.removeAll{ $0 == removeThis }
                
                //reset the tableview
                resetAndShuffle(completionHandler: {
                    didReset in
                    
                    //set the layout on the table to update the new position of the tableview(repositioned back at the top)
                    self.tableView.layoutIfNeeded()
                    
                    //if the reset returned true then 'spin the wheel' and present a restauraunt
                    if didReset == true {
                        //spin the wheel
                        self.spinthewheel()
                    }
                    
                })
                //set the continuebutton to be enabled again
                continueButton.isEnabled = true
                
            }else {
                //spin the wheel
                spinthewheel()
                //set the continuebutton to be enabled again
                continueButton.isEnabled = true
                //change the haspun var to true
                hasSpun = true
            }
            
        }
        //if phase2 is not been enabled yet
        else{
            //hide the tableview
            tableView.isHidden = true
            
            //1.set the edit button to be hidden
            //2.set the 'spinbutton' to be "spin the wheel"
            //3.double the tableviewcells and then make sure the scrollview is at the top
            //4.shuffle the restaraunts
            //5.change the phase so we can control flow with the button
            editButton.isHidden = true
            continueButton.setTitle("Spin the wheel", for: .normal)
            restaurants += restaurants
            restaurants = restaurants.shuffled()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.continueButton.isEnabled = true
                self.tableView.isHidden = false
                self.tableView.isScrollEnabled = false
                self.phase2 = true
            }
        }
        
    }
    
    //MARK: WHEEL SPIN FUNCTION
    func spinthewheel(){
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        
        UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            self.tableView.contentOffset = CGPoint(x: 0, y: -125)
            self.tableView.layoutIfNeeded()
            
            generator.impactOccurred()
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: 650)
                self.tableView.layoutIfNeeded()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 1300)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        
                        self.tableView.setContentOffset(CGPoint(x: 0, y: 1950), animated: false)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        self.grabSelectedRestaraunt()
                        
                    })
                    
                })
                
            })
            
        })
        
        
    }
    
    //MARK: GRAB THE 'WINNING' INDEXPATH
    func grabSelectedRestaraunt(){
        
        //1.grab the visible tableview cells
        //2.pick the middle most number
        //3.either display a view or just automatically bring them back to the main screen
        
        //grab the contentoffset before reload
        let visibleCells = tableView.indexPathsForVisibleRows
        print(Int(visibleCells!.count / 2))
        tableView.selectRow(at: visibleCells![Int(visibleCells!.count / 2)], animated: true, scrollPosition: .middle)
        //set the currently selectedRow, used to remove and view cells
        currentlySelectedCell = visibleCells![Int(visibleCells!.count / 2)]
        
        //1. set the selected details for the restauraunt in the VIEW
        //2. animate the view covering the tableview to be heavily tinted
        //3. animate in the view
        
        
        //1. set the data
        //grab the current cell
        let currentCell = tableView.cellForRow(at: currentlySelectedCell) as! restarauntTableViewCell
        //grab the current model data for the specific cell
        let currentModel = restaurants[currentlySelectedCell.row]
        
        
        var address:String!
        //set the mapview location based on the restauraunt address
        if currentModel.location.display_address[0] != "" {
            address = "\(currentModel.location.display_address[0])"
        }else if currentModel.location.display_address[0] != "" && currentModel.location.display_address[1] != "" {
            address = "\(currentModel.location.display_address[0]), \(currentModel.location.display_address[1])"
        }
        
        //init a geocoder
        let geocoder = CLGeocoder()
        //convert the address above to a location that we can use on the map
        geocoder.geocodeAddressString(address, completionHandler: { placemarks,error in
            
            //check the placemarks using a guard statement
            guard let placemarks = placemarks,
                  let firstLoc = placemarks.first?.location
            else {
                return
            }
            
            //if the guard did not fall through set the location on the mapview here
            let newRegion = MKCoordinateRegion(center: firstLoc.coordinate, latitudinalMeters: 2500, longitudinalMeters: 2500)
            self.restaurantSelectedMapView.setRegion(newRegion, animated: false)
            
            //remove all existing markers on the map
            self.restaurantSelectedMapView.removeAnnotations(self.restaurantSelectedMapView.annotations)
            
            let mapMarker = MKPointAnnotation()
            mapMarker.coordinate = firstLoc.coordinate
            mapMarker.title = "\(currentModel.name)"
            
            //add the annotation to the map
            self.restaurantSelectedMapView.addAnnotation(mapMarker)
            
            
            
            
            
            //if the user wants directions we need to give it to them, for this we will use a mapitem
            let directionsMapItem = MKMapItem(placemark: MKPlacemark(coordinate: firstLoc.coordinate))
            directionsMapItem.name = "\(currentModel.name)"
            //set this top level to our other mapitem
            self.directionsForMap = directionsMapItem
            
        })
        
        //copy contents from the cell over to the main view
        //set the title
        restaurantSelectedTitle.text = currentCell.restarauntTitle.text
        //set the distance
        restaurantSelectedDistance.text = currentCell.distanceLabel.text
        //set the reviews
        restaurantSelectedReviews.text = currentCell.totalReviewsLabel.text
        //set the tags
        restaurantSelectedTags.text = currentCell.tagsLabel.text
        //set the pricelevel
        restaurantSelectedPricerange.attributedText = currentCell.totalPriceLabel.attributedText
        //set the pickup image
        restaurantSelectedPickupImage.image = currentCell.pickupImageView.image
        restaurantSelectedPickupImage.tintColor = currentCell.pickupImageView.tintColor
        //set the delivery image
        restaurantSelectedDeliveryImage.image = currentCell.deliveryImageView.image
        restaurantSelectedDeliveryImage.tintColor = currentCell.deliveryImageView.tintColor
        //set the phone number
        restaurantSelectedPhonenumber.text = currentModel.display_phone
        
        //set the phone number for the call feature
        phonenumberForCall = currentModel.display_phone
        
        
        //favview1
        if currentCell.halfLikeView1.isHidden == true {
            restaurantSelectedFavview1.backgroundColor = currentCell.favView1.backgroundColor
            restaurantSelectedFavView1HalfView.isHidden = true
        }else{
            restaurantSelectedFavview1.backgroundColor = UIColor.lightGray
            restaurantSelectedFavView1HalfView.isHidden = false
        }
        
        //favview2
        if currentCell.halfLikeView2.isHidden == true {
            restaurantSelectedFavview2.backgroundColor = currentCell.favView2.backgroundColor
            restaurantSelectedFavView2HalfView.isHidden = true
        }else{
            restaurantSelectedFavview2.backgroundColor = UIColor.lightGray
            restaurantSelectedFavView2HalfView.isHidden = false
        }
        
        //favview3
        if currentCell.halfLikeView3.isHidden == true {
            restaurantSelectedFavview3.backgroundColor = currentCell.favView3.backgroundColor
            restaurantSelectedFavView3HalfView.isHidden = true
        }else{
            restaurantSelectedFavview3.backgroundColor = UIColor.lightGray
            restaurantSelectedFavView3HalfView.isHidden = false
        }
        
        //favview4
        if currentCell.halfLikeView4.isHidden == true {
            restaurantSelectedFavview4.backgroundColor = currentCell.favView4.backgroundColor
            restaurantSelectedFavView4HalfView.isHidden = true
        }else{
            restaurantSelectedFavview4.backgroundColor = UIColor.lightGray
            restaurantSelectedFavView4HalfView.isHidden = false
        }
        
        //favview5
        if currentCell.halfLikeView5.isHidden == true {
            restaurantSelectedFavview5.backgroundColor = currentCell.favView5.backgroundColor
            restaurantSelectedFavView5HalfView.isHidden = true
        }else{
            restaurantSelectedFavview5.backgroundColor = UIColor.lightGray
            restaurantSelectedFavView5HalfView.isHidden = false
        }
        
        
        //2. animate the view from being hidden to not hidden
        tableViewTintOverlayView.isHidden = false
        UIView.animate(withDuration: 0.8, animations: {
            
            self.tableViewTintOverlayView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.58)
            
            //3. animate the view in
            self.restaurantSelectedView.alpha = 1
            //set the userInteraction to enabled so the users can use the buttons
            self.restaurantSelectedView.isUserInteractionEnabled = true
            
        }, completion: { _ in
            
        })
        
    }
    
    //MARK: RE-SETTING THE TABLEVIEW
    func resetAndShuffle(completionHandler: @escaping (Bool) -> ()){
        //1.shuffle the data in the list
        //2.scroll to the top cell
        //3.re-hide the tint and the selectedView.alpha
        //4.reload the data
        
        //1.
        if restaurants.count < 30 {
            print("p:",restaurants.count)
            restaurants += restaurants
        }
        restaurants = restaurants.shuffled()
        
        //3
        UIView.animate(withDuration: 0.2, animations: {
            
            self.tableViewTintOverlayView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
            self.restaurantSelectedView.alpha = 0
            //set the userInteraction to disabled
            self.restaurantSelectedView.isUserInteractionEnabled = false
            
        }, completion: { _ in
            
        })
        
        
        DispatchQueue.main.async {
            //4
            self.tableView.reloadData()
            //2
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            completionHandler(true)
        }
    
    }
    
    //MARK: REVERSE GEOCODE LAT/LONG TO ADDRESS
    //this function is used to convert a users lat/longs to an actual address, done this way because yelp's API works better with streets than lat/longs
    func geocodeLocation(lat: Double,long: Double) {
        
        //create a geocoder
        let geoCoder = CLGeocoder()
        //init a location from the users lat/long
        let location = CLLocation(latitude: lat , longitude: long)
        
        //create a variable to hold the address
        var address:String = ""
        
        //reverse the lat/long coords
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
 
            if let marker = placemarks?.first {
                
                let street = marker.subThoroughfare ?? ""
                let city = marker.thoroughfare ?? ""
                let province = marker.locality ?? ""
                let zip = marker.postalCode ?? ""
                let country = marker.country ?? ""
                
                //set the address string to be that of the conjoined address
                address = "\(street), \(city), \(province), \(zip), \(country)"
                
                //now that we have the address fire the search
                //tableview delegete set inside return delegate function
                self.ViewModel.getCloseRestaraunts(address: address ,options: self.filterOptions,categories: self.categories)
                
                
            }
            
        })
                
    }
    
    
}

extension restaurantsListTableviewController: UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if restaurants.isEmpty == false {
            return restaurants.count
        }else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if phase2 == false {
            return .delete
        }else{
            return .none
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            
            //remove the selected cell
            self.restaurants.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            
            //set the continue button with the total left
            continueButton.setTitle("Continue(\(restaurants.count))", for: .normal)
            
            break
        default:
            //code goes here
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //grab the restaraunt data for the current cell index
        let currentRestaraunt:restaurant = restaurants[indexPath.row]
        
        let testCell = tableView.dequeueReusableCell(withIdentifier: "restaurantTableviewCell") as! restarauntTableViewCell
        
        //set a corner radius on the cell
        testCell.dataView.layer.cornerRadius = 15
        
        //set the title
        testCell.restarauntTitle.text = "\(currentRestaraunt.name)"
        
        //set the distance
        if currentRestaraunt.distance < 1000 {
            
            let distance: Int = Int(currentRestaraunt.distance)
            
            //set the distance in meteres
            testCell.distanceLabel.text = "\(distance) m"
            
        }else {
            let distance: Double = Double(currentRestaraunt.distance / 1000)
            let totaldistanceString: String = String(format: "%.1f", distance)
            //set the distance in km
            testCell.distanceLabel.text = "\(totaldistanceString) km"
            
        }
        
        
        //hide the half cells
        testCell.halfLikeView1.isHidden = true
        testCell.halfLikeView2.isHidden = true
        testCell.halfLikeView3.isHidden = true
        testCell.halfLikeView4.isHidden = true
        testCell.halfLikeView5.isHidden = true
        
        
        //set the rating
        if currentRestaraunt.rating == 5 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            testCell.favView4.backgroundColor = UIColor.red
            testCell.favView5.backgroundColor = UIColor.red
            
        }else if currentRestaraunt.rating == 4.5 {
            
            //1. set the cells up to the 4rd fav cell
            //2. on the 4th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            testCell.favView4.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView5.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 4 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            testCell.favView4.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 3.5 {
            
            //1. set the cells up to the 3rd fav cell
            //2. on the 3th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView4.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 3 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            testCell.favView3.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 2.5 {
            
            //1. set the cells up to the 2rd fav cell
            //2. on the 2th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView3.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
            
        }else if currentRestaraunt.rating == 2 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            testCell.favView2.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 1.5 {
            
            //1. set the cells up to the 1rd fav cell
            //2. on the 1th fav cell set the halflikeView to be unhidden
            
            //1
            testCell.favView1.backgroundColor = UIColor.red
            
            //2
            //set the correct cell to be hidden
            testCell.halfLikeView2.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
            
        }else if currentRestaraunt.rating == 1 {
            
            //set the current cells
            testCell.favView1.backgroundColor = UIColor.red
            
            //set the buttons to grey
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
        }else if currentRestaraunt.rating == 0.5 {
            
            //1. on the 1th fav cell set the halflikeView to be unhidden
            
            //1
            //set the correct cell to be hidden
            testCell.halfLikeView1.isHidden = false
            
            //set the background cell to be lightgray
            testCell.favView1.backgroundColor = UIColor.lightGray
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
            
            
        }else if currentRestaraunt.rating == 0 {
            //set the buttons to grey
            testCell.favView1.backgroundColor = UIColor.lightGray
            testCell.favView2.backgroundColor = UIColor.lightGray
            testCell.favView3.backgroundColor = UIColor.lightGray
            testCell.favView4.backgroundColor = UIColor.lightGray
            testCell.favView5.backgroundColor = UIColor.lightGray
        }
        
        
        //set review count
        testCell.totalReviewsLabel.text = "\(currentRestaraunt.review_count) reviews"
        
        //set the categories
        //this string will be the final representation of the tags label output string
        var finalString = ""
        for cat in currentRestaraunt.categories {
            if cat == currentRestaraunt.categories.last {
                finalString.append("\(cat.title)")
            }else {
                finalString.append("\(cat.title),")
            }
        }
        //set the tags label
        testCell.tagsLabel.text = finalString
        
        //set the pricerange
        print("test:",currentRestaraunt.price)
        
        //create a variable holding the price text
        let priceString = "$$$$"
        var myMutableString = NSMutableAttributedString()
        
        if currentRestaraunt.price == "$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:1))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:2))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:2))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location:0,length:3))
            testCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "" {
            testCell.totalPriceLabel.text = "$$$$"
        }
        
        //set the pickup/delivery availability
        //check if the restaraunt has 'transactions'
        if currentRestaraunt.transactions.isEmpty == false{
            
            if currentRestaraunt.transactions.contains("delivery") {
                //set the available image for delivery
                testCell.pickupImageView.image = #imageLiteral(resourceName: "check-mark")
                testCell.pickupImageView.tintColor = UIColor.green
                
            }else {
                //set the image to be 'not available'
                testCell.pickupImageView.image = #imageLiteral(resourceName: "cancel")
                testCell.pickupImageView.tintColor = UIColor.red
                
            }
            
            if currentRestaraunt.transactions.contains("pickup") {
                //set the available image for pickup
                testCell.deliveryImageView.image = #imageLiteral(resourceName: "check-mark")
                testCell.deliveryImageView.tintColor = UIColor.green
                
            }else {
                //set the image to be 'not available'
                testCell.deliveryImageView.image = #imageLiteral(resourceName: "cancel")
                testCell.deliveryImageView.tintColor = UIColor.red
            }
            
            
        }
        
        
        return testCell
        
    }
    
}

extension restaurantsListTableviewController:restarauntsViewModelDelegate {
    
    //this function will return our converted restaraunts
    func returnCloseRestaraunts(closeRestaraunts: [restaurant]?) {
        
        //set the restauraunts array to be that of the returned array
        self.restaurants = closeRestaraunts
        
        //using the main thread for UI updates
        DispatchQueue.main.async {
            //reload the data
            self.tableView.reloadData()
            //unhide the tableview
            self.tableViewHolder.isHidden = false
            //stop the indicatorview
            self.indicatorView.stopAnimating()
            
            //set the continue button with the total left
            self.continueButton.setTitle("Continue(\(self.restaurants.count))", for: .normal)
        }
        
        
    }
    
    
    
    
}
