//
//  restarauntAPINetwork.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit

class restarauntAPINetwork {
    
    //create a connection to our API key
    let apiKey = "VxAW4lLM7C0b7akdDiwn-V_Th6viGBmWnKw-B1DoLmSiZjy-0O9x8MgSIuD1DbGT5r8uPEewBWWsY46Aspbg0okyzOrAtTJvISCHV8eM24U2ba9tlfMT1JNce6wDYHYx"
    
    //this will connect the endpoint
    let endpoint = "https://api.yelp.com/v3/businesses/search"
    
    func getCloseRestaraunts(priceLevel:String,address:String,radius:String,categories:String, completionHandler: @escaping ([restaurant]) -> ()){
        
        var url = URLComponents(string: "\(endpoint)")!
        
        url.queryItems = [
            URLQueryItem(name: "term", value: "food"),
            URLQueryItem(name: "price", value: priceLevel),
            URLQueryItem(name: "location", value: address),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "sort_by", value: "distance"),
            URLQueryItem(name: "limit", value: "40"),
            URLQueryItem(name: "categories", value: categories)
        ]
        
        //create the request we will send off to our server
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        //specify the content we will be sending through the post request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //specify the content we will be receiving through the post request
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //add the access token so that the user can send the request so it can be verifyied
        request.setValue("Bearer "+"\(apiKey)", forHTTPHeaderField: "Authorization")
        
        
        let grabCloseRestaraunts = URLSession.shared.dataTask(with: request) {
            (data,response,error) in
            
            if let error = error {
                print("There was an error grabbing the data: \(error.localizedDescription)")
            }else {
                do{
                    
                    guard let data = data else {return}
                    //using JSONSerialization this will return the object inside of foundation objects, this makes it easy for us to parse through
                    let jsonResponseObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    
                    let businessesArray = jsonResponseObject["businesses"] as? [[String : Any]]
                    
                    //this will be the array returned to the viewcontroller
                    var convertedArray:[restaurant] = []
                    
                    if businessesArray?.isEmpty == false {
                        
                        for restaurant in businessesArray! {
                            
//                            print("--------------------------------")
//                            print(restaurant["name"] as? String)
//                            print(restaurant["url"] as? String)
//                            print(restaurant["review_count"] as? Int)
//                            print(restaurant["rating"] as? Double)
//                            print(restaurant["phone"] as? String)
//                            print(restaurant["display_phone"] as? String)
//                            print(restaurant["distance"] as? Double)
//                            print(restaurant["price"] as? String)

//                            print(self.convertRestaurantFromJson(fromJSON: restaurant))

                            convertedArray.append(self.convertRestaurantFromJson(fromJSON: restaurant)!)
                            

                        }
                        
                        completionHandler(convertedArray)
                                                
                    }
                    
                    
                }catch let error {
                    print("problem creating json object: \(error.localizedDescription)")
                    
                }
                                
            }
        }
        grabCloseRestaraunts.resume()
        
    }
    
    func convertRestaurantFromJson(fromJSON json: [String:Any]) -> restaurant? {
        
        //create guard statement to
        guard let name = json["name"] as? String,
              let url = json["url"] as? String? ?? "",
              let review_count = json["review_count"] as? Int,
              let rating = json["rating"] as? Double? ?? 0,
              let phone = json["phone"] as? String? ?? "",
              let display_phone = json["display_phone"] as? String? ?? "",
              let distance = json["distance"] as? Double,
              let price = json["price"] as? String? ?? "",
              let categoriesArray = json["categories"] as? Array<Any>,
              let transactionArray = json["transactions"] as? [String]? ?? [""],
              let locationArray = json["location"] else {
            
            print("not enough, or wrong information to make: restaurant object")
            return nil
        }
        
        
        var categoryArray:[category] = []
        for cat in categoriesArray {
            categoryArray.append(self.convertCategoryFromJson(json: cat as! [String : Any])!)
        }
        
        let location = self.convertLocationFromJson(json: locationArray as! [String : Any])! as location
        
        
        return restaurant(name: name, url: url, review_count: review_count, rating: rating, phone: phone, display_phone: display_phone, distance: distance,price: price,categories: categoryArray,location: location, transactions: transactionArray)
    }
    
    func convertCategoryFromJson( json: [String:Any]) -> category? {
    
        guard let alias = json["alias"] as? String,
              let title = json["title"] as? String else {
            print("not enough, or wrong information to make: Category object")
            return nil
        }
        
        return category(alias: alias, title: title)
    }
    
    func convertLocationFromJson( json: [String:Any]) -> location? {
    
        
        guard let address1 = json["address1"] as? String? ?? "",
              let address2 = json["address2"] as? String? ?? "",
              let address3 = json["address3"] as? String? ?? "",
              let city = json["city"] as? String,
              let zip_code = json["zip_code"] as? String,
              let country = json["country"] as? String,
              let state = json["state"] as? String,
              let display_address = json["display_address"] as? [String] else {
            print("not enough, or wrong information to make: Location object")
            return nil
        }
        
        
        return location(address1: address1, address2: address2, address3: address3, country: country, city: city, zip_code: zip_code, state: state, display_address: display_address)
    }
    
}
