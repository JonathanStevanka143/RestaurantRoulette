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
    
    //this is the view that holds the data, used for adding a corner radius and giving it a nice "pop" look
    @IBOutlet var dataView: UIView!
    
    @IBOutlet var restarauntTitle: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var totalReviewsLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    
    @IBOutlet var pickupImageView: UIImageView!
    @IBOutlet var deliveryImageView: UIImageView!
    
    @IBOutlet var ratingImageView: UIImageView!
    
}
