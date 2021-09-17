//
//  customLocationViewController.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import UIKit
import GoogleMobileAds
import Foundation
import MapKit

class customLocationViewController: UIViewController {
    
    //map
    @IBOutlet var customLocationMap: MKMapView!
    
    //button
    @IBOutlet var selectMapLocation: UIButton!
    
    @IBOutlet var adBannerView: UIView!
    
    //this will allow us to display the ad to our users
    var bannerAD: GADBannerView!
    
    //this var will hold the center of the map coord
    var centerMapCoord:CLLocationCoordinate2D!
    //this will hold the filter options saved on the phone
    var filterOptions:FilterSettings!
    //this array of categories is what the user currently wants to search nearby with
    var categories:[Categories]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the adview here, make the ad size the size of our bannerAdView frame
        bannerAD = GADBannerView(adSize: GADAdSizeFromCGSize(adBannerView.frame.size))
        
        //add the bannerAD to the bannerView
        adBannerView.addSubview(bannerAD)
        
        //setup the ad properties
        bannerAD.adUnitID = "ca-app-pub-8976469642443868/6764145597"
        bannerAD.rootViewController = self
        //load the GAD request so that we can display it to the user
        bannerAD.load(GADRequest())
        //set the delegate for the bannerAD
        bannerAD.delegate = self
        
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

extension customLocationViewController:GADBannerViewDelegate {
    
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

