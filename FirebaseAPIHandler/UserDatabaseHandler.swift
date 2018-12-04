//
//  UserDatabaseHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/29/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import TWMessageBarManager

extension FirebaseAPIHandler {
    
    func signUp(email: String, password: String, fullName: String, profileImage: UIImage?, coordinates: String, completion: @escaping (Bool) -> ())
    {
        // Use DispatchGroup here
        // Escaping Closure / Callback
        Auth.auth().createUser(withEmail: email, password: password)
        {
            (authResult, error) in
            if error == nil {
                guard let user = authResult?.user else { return }
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Account succesfully created!", type: .success)
                // Escaping Closure / Callback
                self.databaseReference.child("USERS").child(user.uid).setValue(["FullName": fullName, "EmailId": email, "Coordinates": coordinates])
                {
                    (error, ref) in
                    if error == nil {
                        // Escaping Closure / Callback
                        if profileImage != nil {
                            FirebaseAPIHandler.shared.uploadImage(folder: FirebaseAPIHandler.storageFolders.userImagesFolder, id: user.uid, image: profileImage!)
                            {
                                (success) in
                                // Escaping Closure / Callback (to Main Queue)
                                self.currentUser = UserModel(id: user.uid, email: email, fullName: fullName, profileImage: profileImage, coordinates: coordinates)
                                completion(true)
                            }
                        } else {
                            self.currentUser = UserModel(id: user.uid, email: email, fullName: fullName, profileImage: profileImage, coordinates: coordinates)
                            completion(true)
                        }
                    } else {
                        completion(false)
                    }
                }
            } else {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error?.localizedDescription, type: .error)
                completion(false)
            }
        }
    }
    
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
    func fetchAllUsers(completion: @escaping ([UserModel]?) -> ())
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
                        objc_sync_enter(userModelArray) // TODO: this does not work on arrays... are arrays thread-safe?
                        userModelArray.append(userModel)
                        objc_sync_exit(userModelArray) // TODO: they're not safe on reference types
                    }
                    fetchingUsersDispatchGroup.leave()
                }
            }
            fetchingUsersDispatchGroup.notify(queue: .global())
            {
                completion(userModelArray)
            }
        }
    }
    
    // TODO: Allow the user to change their email (also authentication requirement!)
    func updateUserProfile(userModel: UserModel, completion: @escaping () -> ())
    {
        let updateUserProfileDispatchGroup = DispatchGroup()
        updateUserProfileDispatchGroup.enter()
        databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).child(userModel.id).updateChildValues(["FullName": userModel.fullName!, "Email": userModel.email!])
        {
            (error, ref) in
            updateUserProfileDispatchGroup.leave()
        }
        if let replacement = userModel.profileImage {
            updateUserProfileDispatchGroup.enter()
            updateImage(folder: FirebaseAPIHandler.storageFolders.userImagesFolder, id: userModel.id, replacement: replacement)
            {
                (success) in
                updateUserProfileDispatchGroup.leave()
            }
        }
        updateUserProfileDispatchGroup.notify(queue: .global())
        {
            self.currentUser?.fullName = userModel.fullName
            self.currentUser?.email = userModel.email
            NotificationCenter.default.post(name: FirebaseAPIHandler.shared.userProfileChangeNotification, object: nil)
            completion()
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
        // get strings of friends
        // call getUser w/ the array of strings
    }
}
