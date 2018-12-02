//
//  DatabaseHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/26/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class DatabaseHandler {
    
    static var shared = DatabaseHandler()
    
    var databaseReference: DatabaseReference!
    
    // all of the users
    var dataSource_userModelArray = Array<UserModel>()
    
    private init()
    {
        databaseReference = Database.database().reference()
    }
    
    func fetchUser(userID: String, completion: @escaping (UserModel?) -> ())
    {
        databaseReference.child("USERS").child(userID).observeSingleEvent(of: .value)
        {
            (snapshot) in
            guard let userInformation = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            print(userInformation["FullName"] as! String)
//            let name = userInformation["FullName"] as? String
//            let email = userInformation["EmailId"] as? String
//            let friends = userInformation["Friends"] as? Array<UserModel>
            
        }
    }
    
    func fetchUserList(completion: @escaping ([UserModel]?) -> ())
    {
        var userModelArray = Array<UserModel>()
        let dispatchGroup_users = DispatchGroup.init()
        let dispatchGroup_images = DispatchGroup.init()
        
        dispatchGroup_users.enter()
        databaseReference.observeSingleEvent(of: .value)
        {
            (snapshot) in
            
            // All the Data
            guard let data = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            // Each Folder in Data
            for folder in data {
                if folder.key == "USERS" {
                    guard let users = folder.value as? [String: Any] else {
                        completion(nil)
                        return
                    }
                    for user in users {
                        let userID = user.key
                        guard let information = user.value as? [String: Any] else {
                            return
                        }
                        guard let email = information["EmailId"] as? String, let fullName = information["FullName"] as? String else {
                            return
                        }
                        let coordinates = information["Coordinates"] as? String ?? "0.0,0.0"
                        //print(coordinates)
                        // downloading the image from the database
                        dispatchGroup_images.enter()
                        var profileImage: UIImage?
                        StorageHandler.shared.pullImage(folder: StorageHandler.shared.folders.userImageFolder, id: userID)
                        {
                            (image) in
                            profileImage = image
                            userModelArray.append(UserModel(id: userID, email: email, fullName: fullName, profileImage: profileImage, coordinates: coordinates))
                            dispatchGroup_images.leave()
                        }
                    }
                    
                    dispatchGroup_images.notify(queue: .main){
                        dispatchGroup_users.leave()
                    }
                    
                    dispatchGroup_users.notify(queue: .main){
                        completion(userModelArray)
                    }
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
}
