//
//  restarauntsListTableviewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import GoogleMobileAds
import AVFoundation
import CoreData
import MapKit
import CoreLocation

class restaurantsListTableviewController: UIViewController {
    
    //AD VIEWS
    @IBOutlet var bannerAdView: UIView!
    
    //FIRST PHASE OUTLETS
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
    
    @IBOutlet var restaurantSelectedFavouriteButton: UIButton!
    @IBOutlet var restaurantSelectedRatingImageView: UIImageView!
    @IBOutlet var callCircleView: UIView!
    @IBOutlet var callButton: UIButton!
    
    @IBOutlet var directionsCircleView: UIView!
    @IBOutlet var directionsButton: UIButton!
    
    @IBOutlet var websiteCircleView: UIView!
    @IBOutlet var websiteButton: UIButton!
    
    //buttons
    @IBOutlet var continueButton: UIButton!
    
    //MARK: AD VARIABLES
    //this will allow us to display an ad to the users
    var bannerAD: GADBannerView!
    //this var represents the fullpage ad that gets triggered every 15 clicks
    private var interstitial: GADInterstitialAd?
    
    //MARK: FIRST PHASE VARIABLES
    //this holds the map coords that the user wanted to use
    var centerMapCoord: CLLocationCoordinate2D!
    //filter options from the phone, set by the sending VC
    var filterOptions:FilterSettings!
    //this array of categories is what the user currently wants to search nearby with
    var categories:[Categories]!
    //hook up the view model(where updates will be made etc)
    var ViewModel = restarauntsViewModel()
    //use the favouritesviewmodel so that we can access the save methods(code reusability)
    var favRestaurantViewModel = favouriteViewModel()
    //this will hold all of the tableview data
    var restaurants:[restaurant]! = []
    
    //MARK: SECOND PHASE VARIABLES
    //this holds the currently selected cell number
    var currentlySelectedCell:IndexPath! = nil
    //this variable will hold the favourite restaurant data to compare against
    var userFavourites:[FavouriteRestaurant]!
    //this variable will represent the viewmodel for the favourites controller, this way we can access the data instead of repeating code
    var favViewModel = favouriteViewModel()
    //per apple documentation use this when we are adding or removing objects from the core data stack such as hitting the "favourite button"
    var container: NSPersistentContainer! {
        //this allows it to work on all IOS levels supported
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    //MARK: Favourites spin variables
    //create a variable to represent the view being used for favourites so we can set the view up to detect this change
    var is_spinning_favourites:Bool = false
    
    override func viewDidLoad() {
        
        //setup the adview here, make the ad size the size of our bannerAdView frame
        bannerAD = GADBannerView(adSize: GADAdSizeFromCGSize(bannerAdView.frame.size))
        
        //add the bannerAD to the bannerView
        bannerAdView.addSubview(bannerAD)
        
        //setup the ad properties
        bannerAD.adUnitID = "ca-app-pub-8976469642443868/2028190240"
        bannerAD.rootViewController = self
        //load the GAD request so that we can display it to the user
        bannerAD.load(GADRequest())
        //set the delegate for the bannerAD
        bannerAD.delegate = self
        
        //create a request to load the interstitial ad in
        let request = GADRequest()
        //load an ad
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-8976469642443868/9028712867",
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                //set the ad
                                interstitial = ad
                                //set the
                                interstitial?.fullScreenContentDelegate = self
                               }
        )
        
        
        
        
        //set the view model delegate for this page
        ViewModel.delegate = self
        //set the delegate for the favourites view model this way we can run the favourites against the currently retreived. better UX
        favViewModel.delegate = self
        //        print("Device:",UIDevice.modelName)
        
        //check if the view is spinning favourites
        favViewModel.grabFavourites()
        
        //disable the continue button until results have loaded in
        continueButton.isEnabled = false
        
        //1.create a function to reverse geocode an address and pass it to the API for more accurate results
        if is_spinning_favourites == false {
            geocodeLocation(lat: centerMapCoord.latitude, long: centerMapCoord.longitude)
        }else{
            //set the title for the controller to represent whats being spun
            self.title = "Favourites"
            //load the faved restaurants
            print(restaurants.count)
            
            if restaurants.count != 0 {
                //unhide the view
                tableViewHolder.isHidden = false
                //enable the button
                continueButton.isEnabled = true
                continueButton.isUserInteractionEnabled = true
                //set the button text
                continueButton.setTitle("Shuffle & Spin", for: .normal)
            }
            
        }
        
        
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
        //directionview setup
        directionsCircleView.layer.cornerRadius = 30
        //website setup
        websiteCircleView.layer.cornerRadius = 30
        //favourite button setup
        restaurantSelectedFavouriteButton.layer.cornerRadius = 20
        
        if is_spinning_favourites == true{
            spinTheWheelButtonPressed(self)
        }
    }
    
    
    //MARK: BUTTON ACTIONS
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
        
        DispatchQueue.main.async {
            self.directionsForMap.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
        
    }
    
    //create a bool value to deal if the button has been clicked before or not
    var is_favourited:Bool! = false
    @IBAction func FavouriteButtonClicked(_ sender: Any) {
        //use this generator for the button click
        //grab the current model
        let currentModel = restaurants[currentlySelectedCell.row]
        if is_favourited == false {
            //set the image on the button to be heart.fill
            restaurantSelectedFavouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            //create an impact
            generator.impactOccurred()
            //set the model to represent that it is a favourite
            currentModel.is_favourite = true
            favRestaurantViewModel.saveRestaurant(restaurant: currentModel)
            //set the bool value to indicate that it has been saved
            is_favourited = true
            //grab the updated list
            favViewModel.grabFavourites()
        }else if is_favourited == true {
            //delete the object from the MOC
            if userFavourites != nil {
                for rest in userFavourites {
                    if currentModel.id == rest.id {
                        container.viewContext.delete(rest)
                        //save the currentContext so that our changes are persisteddx
                        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                        break
                    }
                }
            }
            
            //set the image on the button to be heart.fill
            restaurantSelectedFavouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            currentModel.is_favourite = false
            //set the bool value to indicate that it has been un-saved
            is_favourited = false
        }
    }
    
    @IBAction func websiteButtonPressed(_ sender: Any) {
        
        if currentlySelectedCell != nil {
            
            //grab the selected data from the array
            let selected = restaurants[currentlySelectedCell.row]
            
            if let websiteURL = URL(string: selected.url){
                
                //run this on the main thread to avoid random crashes in the crash log
                //date- April 30th, 2021
                DispatchQueue.main.async {
                    UIApplication.shared.open(websiteURL, options: [:], completionHandler: nil)
                }
            }else{
                
                //make a popup say invalid or something?
                
            }
            
        }
        
    }
    
    
    //this variable represents the phase of which the tableview is in
    //phase1: the user can edit and remove items off the list, scrollview is still scrollable
    //phase2: the 'game' has now begun the user has to click the spin button and the tableview will automatically begin the animation down, the data is also shuffled
    var phase2:Bool! = false
    //this represents if the tableview has been spun yet, this will allow us to reset the layout if need be
    var hasSpun:Bool! = false
    //create a counter so we can see how many times a user has pressed the button
    //once this hits 5, we will present an ad
    var clickCounter = 0
    @IBAction func spinTheWheelButtonPressed(_ sender: Any) {
        //set the button to be inactive
        continueButton.isEnabled = false
        
        //increase the click counter so when we know when to display an ad
        clickCounter += 1
        
        //if phase2 is set changed the UI accordingly
        if phase2 == true {
            //1.disable scrolling
            //2.set the button to say "remove & spin"
            continueButton.setTitle("Spinning...", for: .normal)
            continueButton.isEnabled = false
            //if the table has been spun and a restauraunt has been selected, remove it
            if hasSpun == true {
                
                //remove the restaraunt from the list so it cant be used again
                let removeThis = restaurants[currentlySelectedCell.row]
                
                //check to see if the array contains all the same element, the same as being at 1 model in the array
                let allModelsTheSame = restaurants.allSatisfy({ $0 == restaurants.first })
                if allModelsTheSame == false {
                    //remove all copies of the model in the tableview data array
                    restaurants.removeAll{ $0 == removeThis }
                }else {
                    
                    //DO SOMETHING HERE INSTEAD OF JUST SPINNING THE VIEW OVER AND OVER
                    
                }
                
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
                
            }else {
                //spin the wheel
                spinthewheel()
                //set the continuebutton to be disabled during the animation block
                continueButton.isEnabled = false
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
            
            //fix the table not having the proper amount of cells to spin the table
            if restaurants.count <= 30 && restaurants.count != 0{
                
                print("30 into 3", 30 / restaurants.count)
                print("leftover", 30 % restaurants.count)
                
                restaurants.append(contentsOf: restaurants)
                restaurants.append(contentsOf: restaurants)
                
                //just incase there is not enough room
                if restaurants.count <= 30 {
                    
                    restaurants.append(contentsOf: restaurants)
                    restaurants.append(contentsOf: restaurants)
                    
                }
                
            }
            
            restaurants += restaurants
            restaurants = restaurants.shuffled()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.continueButton.isEnabled = true
                self.tableView.isHidden = false
                self.tableView.isScrollEnabled = false
                self.phase2 = true
                //reset the tableview
                self.resetAndShuffle(completionHandler: {
                    didReset in
                    
                    //set the layout on the table to update the new position of the tableview(repositioned back at the top)
                    self.tableView.layoutIfNeeded()
                    
                    //if the reset returned true then 'spin the wheel' and present a restauraunt
                    if didReset == true {
                        //spin the wheel
                        self.spinthewheel()
                        self.continueButton.setTitle("Spinning...", for: .normal)
                        self.continueButton.isEnabled = false
                        self.hasSpun = true
                    }
                    
                })
            }
            
        }
        
    }
    
    //MARK: WHEEL SPIN FUNCTION
    func spinthewheel(){
        
        var impactTimer:Timer!
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        
        //check to see if the array contains all the same element, the same as being at 1 model in the array
        let allModelsTheSame = restaurants.allSatisfy({ $0 == restaurants.first })
        //still other options in the array
        if allModelsTheSame == false {
            
        }else {
            //set the continue button to say "Spin" instead of remove and spin
            continueButton.setTitle("Spin", for: .normal)
        }
        
        
        //here we need to check the type of device being used for the app so we can properly set our animations so that it wont make UI errors
        if UIDevice.modelName == "iPhone SE"{
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 350)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 750)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1150), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone SE (2nd generation)" {
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 450)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 850)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1250), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone 6s" || UIDevice.modelName == "iPhone 6s Plus" {
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 450)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 950)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1450), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 7 Plus"{
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 350)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 850)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1350), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone 8" || UIDevice.modelName == "iPhone 8 Plus" {
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 350)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 850)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1350), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
            
        }else if UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone XR" {
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 550)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 1050)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1350), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone XS Max"{
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 550)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 1050)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1350), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone 11" || UIDevice.modelName == "iPhone 11 Pro Max"{
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
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
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone 11 Pro" {
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 450)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 950)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1450), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
            
        }else if UIDevice.modelName == "iPhone 12 mini" {
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 450)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 950)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1450), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }else if UIDevice.modelName == "iPhone 12" || UIDevice.modelName == "iPhone 12 Pro" || UIDevice.modelName == "iPhone 12 Pro Max" {
            
            UIView.animate(withDuration: 0.3, delay: 0.150, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.tableView.contentOffset = CGPoint(x: 0, y: -125)
                self.tableView.layoutIfNeeded()
                
                generator.impactOccurred()
                
            }, completion: { _ in
                
                UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    
                    impactTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mainImpactRythem), userInfo: nil, repeats: true)
                    
                    self.tableView.contentOffset = CGPoint(x: 0, y: 550)
                    self.tableView.layoutIfNeeded()
                    
                }, completion: { _ in
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        
                        self.tableView.contentOffset = CGPoint(x: 0, y: 1150)
                        self.tableView.layoutIfNeeded()
                        
                    }, completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.8, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            
                            self.tableView.setContentOffset(CGPoint(x: 0, y: 1550), animated: false)
                            self.tableView.layoutIfNeeded()
                            
                        }, completion: { _ in
                            //                        impactTimer.invalidate()
                            
                            self.grabSelectedRestaraunt()
                            impactTimer.invalidate()
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }
        
        
        
    }
    
    //MARK: TIMERS FOR IMPACT SENSORS
    //this is the apple pay sound
    let systemSoundID: SystemSoundID = 1322
    //this allows us to let the user feel vibrations
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    @objc func mainImpactRythem() {
        generator.impactOccurred()
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
        
        
        let allModelsTheSame = restaurants.allSatisfy({ $0 == restaurants.first })
        if allModelsTheSame == true {
            //set the title to Spin
            continueButton.setTitle("Spin", for: .normal)
        }else {
            //reset the title as if it was done animating through the block for UIX
            continueButton.setTitle("Remove & Spin", for: .normal)
        }
        //enable the continue button here after setting the currently selected cell incase the user wants to continue
        continueButton.isEnabled = true
        
        //1. set the selected details for the restauraunt in the VIEW
        //2. animate the view covering the tableview to be heavily tinted
        //3. animate in the view
        
        //1. set the data
        //grab the current cell
        let currentCell = tableView.cellForRow(at: currentlySelectedCell) as! restarauntTableViewCell
        //grab the current model data for the specific cell
        let currentModel = restaurants[currentlySelectedCell.row]
        
        //check to see if this model has been favourited before
        if currentModel.is_favourite == true {
            restaurantSelectedFavouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            //set the button bool to match this change
            is_favourited = true
        }else {
            restaurantSelectedFavouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            //set the button bool to match this change
            is_favourited = false
        }
        
        
        var address:String!
        //set the mapview location based on the restauraunt address
        if currentModel.location.display_address.count >= 2{
            if currentModel.location.display_address[0] != "" && currentModel.location.display_address[1] != "" {
                address = "\(currentModel.location.display_address[0]), \(currentModel.location.display_address[1])"
            }
        }else if currentModel.location.display_address[0] != "" {
            address = "\(currentModel.location.display_address[0])"
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
        //set the distance
        restaurantSelectedDistance.text = currentCell.distanceLabel.text
        restaurantSelectedDistance.sizeToFit()
        //set the title
        restaurantSelectedTitle.text = currentCell.restarauntTitle.text
        restaurantSelectedTitle.sizeToFit()
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
        
        
        //set the rating
        if currentModel.rating == 5 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "5StarRating")
            
        }else if currentModel.rating == 4.5 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "4HalfStarRating")
            
        }else if currentModel.rating == 4 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "4StarRating")
            
        }else if currentModel.rating == 3.5 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "3HalfStarRating")
            
            
        }else if currentModel.rating == 3 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "3StarRating")
            
            
        }else if currentModel.rating == 2.5 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "2HalfStarRating")
            
            
        }else if currentModel.rating == 2 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "2StarRating")
            
        }else if currentModel.rating == 1.5 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "1HalfStarRating")
            
            
        }else if currentModel.rating == 1 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "1StarRating")
            
            
        }else if currentModel.rating == 0 {
            //set the imageview
            restaurantSelectedRatingImageView.image = UIImage(named: "0StarRating")
            
        }
        
        
        //2. animate the view from being hidden to not hidden
        tableViewTintOverlayView.isHidden = false
        UIView.animate(withDuration: 0.8, animations: {
            
            self.tableViewTintOverlayView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.58)
            
            //3. animate the view in
            self.restaurantSelectedView.alpha = 1
            
            //play the completion sound
            AudioServicesPlayAlertSound(self.systemSoundID)
            
        }, completion: { _ in
            //set the userInteraction to enabled so the users can use the buttons
            self.restaurantSelectedView.isUserInteractionEnabled = true
            
            //check to see if the click counter is greater than 15, show a full screen ad if it is
            if self.clickCounter == 5 {
                //make sure the ad is not nil
                if self.interstitial != nil {
                    //show the fullscreen ad after a place has been chosen. gives user incentive to watch the ad entirely
                    self.interstitial!.present(fromRootViewController: self)
                    //reset the counter to 0
                    self.clickCounter = 0
                  } else {
                    print("Ad wasn't ready")
                  }
            }
            
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
            //            print("p:",restaurants.count)
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
            if restaurants.count != 1 {
                self.restaurants.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
            }
            
            //set the continue button with the total left
            continueButton.setTitle("Shuffle & Spin(\(restaurants.count))", for: .normal)
            
            break
        default:
            //code goes here
            break
        }
        
    }
    
    //this is for selecting a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //grab the cell connected with the clicked cell
        let currentModel = restaurants[indexPath.row]
        //check if it can be converted to a URL
        if let websiteURL = URL(string: currentModel.url){
            //launch the web view to the internet
            UIApplication.shared.open(websiteURL, options: [:], completionHandler: nil)
            
        }else{
            //make a popup say invalid or something?
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //grab the restaraunt data for the current cell index
        let currentRestaraunt:restaurant = restaurants[indexPath.row]
        
        let currentCell = tableView.dequeueReusableCell(withIdentifier: "restaurantTableviewCell") as! restarauntTableViewCell
        
        //set a corner radius on the cell
        currentCell.dataView.layer.cornerRadius = 15
        
        
        if is_spinning_favourites == false {
            //set the distance
            if currentRestaraunt.distance < 1000 {
                
                let distance: Int = Int(currentRestaraunt.distance)
                
                //set the distance in meteres
                currentCell.distanceLabel.text = "\(distance) m"
                
            }else {
                let distance: Double = Double(currentRestaraunt.distance / 1000)
                let totaldistanceString: String = String(format: "%.1f", distance)
                //set the distance in km
                currentCell.distanceLabel.text = "\(totaldistanceString) km"
                currentCell.distanceLabel.sizeToFit()
            }
        }else{
            currentCell.distanceLabel.text = "\(currentRestaraunt.location.city), \(currentRestaraunt.location.state)"
            currentCell.distanceLabel.sizeToFit()
        }
        
        //set the title
        currentCell.restarauntTitle.text = "\(currentRestaraunt.name)"
        //set the rating
        if currentRestaraunt.rating == 5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "5StarRating")
            
        }else if currentRestaraunt.rating == 4.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "4HalfStarRating")
            
        }else if currentRestaraunt.rating == 4 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "4StarRating")
            
        }else if currentRestaraunt.rating == 3.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "3HalfStarRating")
            
        }else if currentRestaraunt.rating == 3 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "3StarRating")
            
        }else if currentRestaraunt.rating == 2.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "2HalfStarRating")
            
        }else if currentRestaraunt.rating == 2 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "2StarRating")
            
        }else if currentRestaraunt.rating == 1.5 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "1HalfStarRating")
            
        }else if currentRestaraunt.rating == 1 {
            //set the imageview
            currentCell.ratingImageView.image = UIImage(named: "1StarRating")
            
        }else if currentRestaraunt.rating == 0 {
            //set the imageview
            
        }
        
        
        //set review count
        currentCell.totalReviewsLabel.text = "\(currentRestaraunt.review_count) reviews"
        
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
        currentCell.tagsLabel.text = finalString
        
        //set the pricerange
        //        print("test:",currentRestaraunt.price)
        
        //create a variable holding the price text
        let priceString = "$$$$"
        var myMutableString = NSMutableAttributedString()
        
        if currentRestaraunt.price == "$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:1))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:2))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:3))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "$$$$" {
            
            myMutableString = NSMutableAttributedString(string: priceString, attributes: nil)
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1), range: NSRange(location:0,length:4))
            currentCell.totalPriceLabel.attributedText = myMutableString
            
        }else if currentRestaraunt.price == "" {
            currentCell.totalPriceLabel.text = "N/A"
        }
        
        //set the pickup/delivery availability
        //check if the restaraunt has 'transactions'
        if currentRestaraunt.transactions.isEmpty == false{
            
            if currentRestaraunt.transactions.contains("delivery") {
                //set the available image for delivery
                currentCell.pickupImageView.image = #imageLiteral(resourceName: "check-mark")
                currentCell.pickupImageView.tintColor = #colorLiteral(red: 0, green: 0.6039215686, blue: 0.03529411765, alpha: 1)
                
            }else {
                //set the image to be 'not available'
                currentCell.pickupImageView.image = #imageLiteral(resourceName: "cancel")
                currentCell.pickupImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
                
            }
            
            if currentRestaraunt.transactions.contains("pickup") {
                //set the available image for pickup
                currentCell.deliveryImageView.image = #imageLiteral(resourceName: "check-mark")
                currentCell.deliveryImageView.tintColor = #colorLiteral(red: 0.001247007969, green: 0.6028117069, blue: 0.0351134165, alpha: 1)
                
            }else {
                //set the image to be 'not available'
                currentCell.deliveryImageView.image = #imageLiteral(resourceName: "cancel")
                currentCell.deliveryImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
            }
            
            
        }else {
            //set both the pickup and delivery logo to be red x's
            //set the image to be 'not available' for delivery
            currentCell.deliveryImageView.image = #imageLiteral(resourceName: "cancel")
            currentCell.deliveryImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
            //set the image to be 'not available' for pickup
            //set the image to be 'not available'
            currentCell.pickupImageView.image = #imageLiteral(resourceName: "cancel")
            currentCell.pickupImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
        }
        
        
        return currentCell
        
    }
    
}


//MARK: GAD BANNER VIEW DELEGATE METHODS
extension restaurantsListTableviewController:GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
    
}


//MARK: GAD INTERSTITIAL AD DELEGATES
extension restaurantsListTableviewController:GADFullScreenContentDelegate {
    
    // Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    // Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    // Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        //create a request to create a new interstitialAD
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-8976469642443868/9028712867",
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                //set the new ad
                                interstitial = ad
                               }
        )
        
        
    }
    
}


extension restaurantsListTableviewController:restarauntsViewModelDelegate {
    
    //this function will return our converted restaraunts
    func returnCloseRestaraunts(closeRestaraunts: [restaurant]?) {
        
        //set the restauraunts array to be that of the returned array
        self.restaurants = closeRestaraunts
        
        if userFavourites != nil {
            for fav in userFavourites {
                for place in (closeRestaraunts)! {
                    if fav.id == place.id {
                        //set the is_favourited bool in the 'closerestaraunts' array
                        place.is_favourite = true
                    }
                }
            }
        }
        
        //using the main thread for UI updates
        DispatchQueue.main.async {
            //reload the data
            self.tableView.reloadData()
            //unhide the tableview
            self.tableViewHolder.isHidden = false
            //stop the indicatorview
            self.indicatorView.stopAnimating()
            //enable the button
            self.continueButton.isEnabled = true
            //set the continue button with the total left
            self.continueButton.setTitle("Shuffle & Spin(\(self.restaurants.count))", for: .normal)
        }
        
        
    }
    
}
extension restaurantsListTableviewController: favouriteViewModelDelegate {
    
    //set the local data so we can use it
    func returnAllFavourites(favouriteRestaurants: [FavouriteRestaurant]?) {
        userFavourites = favouriteRestaurants
    }
    
}
