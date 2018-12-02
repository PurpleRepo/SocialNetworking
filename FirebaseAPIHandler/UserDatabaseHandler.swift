//
//  UserDatabaseHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/29/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import UIKit

extension FirebaseAPIHandler {
    
    // TODO Need to finish implementing this! (And then use it to fetch all users!)
    func fetchUser(userID: String, completion: @escaping (UserModel?) -> ())
    {
        databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).child(userID).observeSingleEvent(of: .value)
        {
            (snapshot) in
            guard let userInformation = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            var email: String?
            var fullName: String?
            var profileImage: UIImage?
            
            guard let coordinates = userInformation["Coordinates"] as? String else {
                completion(nil)
                return
            }
            
            email = userInformation["EmailId"] as? String
            fullName = (userInformation["FullName"] as? String) ?? "User"
            
            FirebaseAPIHandler.shared.fetchImage(folder: FirebaseAPIHandler.storageFolders.userImagesFolder, id: userID)
            {
                (image) in
                profileImage = image
                if profileImage == nil {
                    profileImage = UIImage(named: "defaultProfileImage")
                }
                let userModel = UserModel.init(id: userID, email: email, fullName: fullName, profileImage: profileImage, coordinates: coordinates)
                completion(userModel)
            }
        }
    }
    
    // TODO Strictly Iterate through the users, calling FetchUser!
    func fetchUserList(completion: @escaping ([UserModel]?) -> ())
    {
        databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).observeSingleEvent(of: .value)
        {
            (snapshot) in
            guard let users = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            var userModelArray = Array<UserModel>()
            let fetchingUsersDispatchGroup = DispatchGroup()
            for user in users {
                let userID = user.key
                fetchingUsersDispatchGroup.enter()
                self.fetchUser(userID: userID)
                {
                    (userModel) in
                    if let userModel = userModel {
                        objc_sync_enter(userModelArray)
                        userModelArray.append(userModel)
                        objc_sync_exit(userModelArray)
                    }
                    fetchingUsersDispatchGroup.leave()
                }
                fetchingUsersDispatchGroup.notify(queue: .global())
                {
                    completion(userModelArray)
                }
            }
        }
    }
    
    func addFriend(for userID: String, friendID: String, completion: @escaping (Bool) -> ())
    {
        databaseReference.child("USERS").child(userID).child("Friends").setValue(friendID)
        {
            (error, ref) in
            if error == nil {
                // UserLoggingHandler.shared.currentUser.friends.append(UserModel(self.fetchUser(friendID))
            }
        }
    }
    
    func fetchFriends(of userID: String, completion: @escaping (Array<UserModel>?) -> ())
    {
        
    }
}
