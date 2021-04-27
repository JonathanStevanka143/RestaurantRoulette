//
//  UIViewExtension.swift
//  Roulette
//
//  Created by Mac User on 2021-04-26.
//

import Foundation
import UIKit

extension UIView {
    
    //lower the save button into view
    func lowerSaveButtonIntoView(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: {
                        self.isHidden = false
                        self.frame.origin.y = 120
                       },
                       completion: { (value: Bool) in
                        if let complete = onCompletion { complete() }
                       }
        )
    }
    
    //raise the save button into view
    func raiseSaveButtonOutOfView(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: {
                        self.frame.origin.y = -50
                       },
                       completion: { (value: Bool) in
                        if let complete = onCompletion { complete() }
                       }
        )
    }
    
}
