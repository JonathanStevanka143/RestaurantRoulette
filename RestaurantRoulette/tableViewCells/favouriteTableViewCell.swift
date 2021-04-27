//
//  favouriteTableViewCell.swift
//  Roulette
//
//  Created by Mac User on 2021-04-25.
//

import Foundation
import UIKit

class favouriteTableViewCell: UITableViewCell {
    
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
    
    
    override func prepareForReuse() {
        //reset visual items
        pickupImageView.image = #imageLiteral(resourceName: "cancel")
        pickupImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
        deliveryImageView.image = #imageLiteral(resourceName: "cancel")
        deliveryImageView.tintColor = #colorLiteral(red: 0.8274509804, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
    }
    
}
