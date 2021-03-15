//
//  restarauntTableViewCell.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-21.
//

import Foundation
import UIKit
import CoreData

class restarauntTableViewCell: UITableViewCell {
    
    @IBOutlet var restarauntTitle: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var totalReviewsLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    
    @IBOutlet var pickupImageView: UIImageView!
    @IBOutlet var deliveryImageView: UIImageView!
    
    //fav view 1
    @IBOutlet var favView1: UIView!
    @IBOutlet var halfLikeView1: UIView!
    
    //fav view 2
    @IBOutlet var favView2: UIView!
    @IBOutlet var halfLikeView2: UIView!
    
    //fav view 3
    @IBOutlet var favView3: UIView!
    @IBOutlet var halfLikeView3: UIView!
    
    //fav view 4
    @IBOutlet var favView4: UIView!
    @IBOutlet var halfLikeView4: UIView!
    
    //fav view 5
    @IBOutlet var favView5: UIView!
    @IBOutlet var halfLikeView5: UIView!
    
}
