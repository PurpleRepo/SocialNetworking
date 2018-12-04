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

class FirebaseAPIHandler {
    
    static let shared = FirebaseAPIHandler()
    
    var databaseReference: DatabaseReference!
    var storageReference: StorageReference!
    
    static let databaseFolders = (usersFolder: "USERS",
                                  postsFolder: "POSTS")
    static let storageFolders = (userImagesFolder: "USERIMAGES",
                                 postImagesFolder: "POSTIMAGES")
    
    var userProfileChangeNotification = Notification.Name.init("UserProfileChange")
    
    var currentUser: UserModel?
    
    private init()
    {
        databaseReference = Database.database().reference()
        storageReference = Storage.storage().reference()
        
        if let user = Auth.auth().currentUser { // make a barrier for this
            fetchUser(userID: user.uid)
            {
                (userModel) in
                objc_sync_enter(self.currentUser as Any)
                self.currentUser = userModel
                objc_sync_exit(self.currentUser as Any)
                DispatchQueue.main.async {
                    self.updateCurrentUserModelReferences()
                }
            }
        }
    }
    
    func updateCurrentUserModelReferences()
    {
        NotificationCenter.default.post(name: userProfileChangeNotification, object: currentUser)
    }
}
