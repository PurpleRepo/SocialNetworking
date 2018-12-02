//
//  FirebaseAPIHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/29/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol UserProfileChangeDelegate {
    func profileChanged()
}

class FirebaseAPIHandler {
    
    static let shared = FirebaseAPIHandler()
    
    var databaseReference: DatabaseReference!
    var storageReference: StorageReference!
    
    static let databaseFolders = (usersFolder: "USERS",
                                  postsFolder: "POSTS")
    static let storageFolders = (userImagesFolder: "USERIMAGES",
                                 postImagesFolder: "POSTIMAGES")
    
    var currentUser: UserModel?
    
    var userProfileChangeDelegates = Array<UserProfileChangeDelegate>()
    
    private init(){
        databaseReference = Database.database().reference()
        storageReference = Storage.storage().reference()
        
        if let user = Auth.auth().currentUser {
            
            let pullingUserModel = DispatchGroup()
            
            // TODO TEMPORARY FIX - MUST IMPLEMENT THE FETCHUSER
            currentUser = UserModel(id: user.uid, email: user.email, fullName: user.displayName, profileImage: nil, coordinates: "")
//            pullingUserModel.enter()
//            fetchUser(userID: user.uid)
//            {
//                (userModel) in
//                self.currentUser = userModel
//                pullingUserModel.leave()
//            }
            
            var profileImage: UIImage?
            pullingUserModel.enter()
            fetchImage(folder: FirebaseAPIHandler.storageFolders.userImagesFolder, id: user.uid)
            {
                (image) in
                profileImage = image
                pullingUserModel.leave()
            }
            
            pullingUserModel.notify(queue: .main)
            {
                self.currentUser?.profileImage = profileImage
                if profileImage != nil {
                    self.currentUser?.profileImageType = ImageType.customImage
                }
                self.updateCurrentUserModels()
            }
        }
    }
}
