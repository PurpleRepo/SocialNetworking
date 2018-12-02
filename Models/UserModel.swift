//
//  UserModel.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/26/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import UIKit

enum ImageType {
    case defaultImage
    case customImage
}

class UserModel {
    
    var id: String
    var loginType: String?
    var email: String?
    var fullName: String?
    var profileImageType: ImageType
    var profileImage: UIImage?
    var coordinates: String
    var latitude: Double
    var longitude: Double
    var friends = Array<UserModel>()
    var outgoingRequests = Array<UserModel>()
    var incomingRequests = Array<UserModel>()
    
    init(id: String, email: String?, fullName: String?, profileImage: UIImage?, coordinates: String)
    {
        self.id = id
        self.email = email
        self.fullName = fullName
        if profileImage != nil {
            self.profileImage = profileImage
            self.profileImageType = ImageType.customImage
        } else {
            self.profileImageType = ImageType.defaultImage
        }
        self.coordinates = coordinates
        
        let coordinatesArray = coordinates.components(separatedBy: CharacterSet(charactersIn: ",")).compactMap({
            Double($0)
        })
        
        // TEMPORARY FIX
//        print("Coordinates Array Count: \(coordinatesArray.count)")
//        if coordinatesArray.count == 0 {
//            latitude = 37.4220
//            longitude = -122.0841
//        } else {
//            
//        }
        
        latitude = coordinatesArray[0]
        longitude = coordinatesArray[1]
    }
}
