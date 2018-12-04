//
//  ProfileImageTemplate.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 12/3/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import UIKit

class ProfileImageTemplate: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.viewBorderWidth = 5
        self.viewCorner = self.frame.height * 0.6
        self.viewBorderColor = UIColor.gray
    }
}
