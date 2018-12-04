//
//  ProfileImageView.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/27/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var viewCorner: CGFloat {    // @IB -> design component
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var viewBorderWidth: CGFloat {
        get {
            return layer.borderWidth
            
        }
        set {
            layer.borderWidth = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var viewBorderColor: UIColor {
        get {
            return UIColor(cgColor:layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
}
