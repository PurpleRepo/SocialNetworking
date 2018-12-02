//
//  UserLoggingHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/21/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import TWMessageBarManager
import Crashlytics
import Fabric
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

//protocol UserProfileChangeDelegate {
//    func profileChanged()
//}

class UserLoggingHandler {
    
    static var shared = UserLoggingHandler()
    
    var currentUser: UserModel?
    var delegates = Array<UserProfileChangeDelegate>()
    
    var databaseReference: DatabaseReference!
    
    private init(){
        print("Initializing UserLoggingHandler!")
        databaseReference = Database.database().reference()
        DispatchQueue.global().async {
            if let user = Auth.auth().currentUser {
                // fetch data of this single user using the UID
//                print(user.uid)
//                print(user.email)
//                print(user.displayName)
                // TODO: MUST BE FIXED
                let userModel = UserModel(id: user.uid, email: user.email, fullName: user.displayName, profileImage: nil, coordinates: "")
                StorageHandler.shared.pullImage(folder: StorageHandler.shared.folders.userImageFolder, id: user.uid)
                {
                    (image) in
                    userModel.profileImage = image
                    DispatchQueue.main.async {
                        self.currentUser = userModel
                        self.updateCurrentUserModels()
                    }
                }
            }
        }
    }
    
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
                            StorageHandler.shared.uploadImage(folder: StorageHandler.shared.folders.userImageFolder, id: user.uid, image: profileImage!)
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
    
    // TODO: Need to include storing storage references
    func signIn(email: String, password: String, completion: @escaping (Error?) -> ())
    {
        Auth.auth().signIn(withEmail: email, password: password)
        {
            (result, error) in
            if error == nil {
                guard let user = result?.user else { return }
                StorageHandler.shared.pullImage(folder: StorageHandler.shared.folders.userImageFolder, id: user.uid)
                {
                    (image) in
                    // TODO: MUST BE FIXED TO PULL FROM STORAGE
                    self.currentUser = UserModel(id: user.uid, email: user.email, fullName: user.displayName, profileImage: image, coordinates: "")
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Successfully signed in!", type: .success)
                    completion(nil)
                }
            } else {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error?.localizedDescription, type: .error)
                completion(error)
            }
        }
    }
    func signIn(with credential: AuthCredential, completion: @escaping (Bool) -> ())
    {
        Auth.auth().signInAndRetrieveData(with: credential)
        {
            (authResult, error) in
            if error == nil {
                guard let user = authResult?.user else { return }
                StorageHandler.shared.pullImage(folder: StorageHandler.shared.folders.userImageFolder, id: user.uid)
                {
                    (image) in
                    // TODO: MUST BE FIXED, PULL FROM STORAGE (DATABASE)
                    self.currentUser = UserModel(id: user.uid, email: user.email, fullName: user.displayName, profileImage: image, coordinates: "")
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Successfully signed in!", type: .success)
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func signOut()
    {
        // Printing user info before logging out.
        /*if let providerInfo = Auth.auth().currentUser?.providerData {
            for userInfo in providerInfo {
                print(userInfo)
                print(userInfo.providerID)
                print(GoogleAuthProviderID)
            }
        } // */
        
        // none of these work outside of the Firebase signout method
        /*if let providerInfo = Auth.auth().currentUser?.providerData {
            for userInfo in providerInfo {
                switch userInfo.providerID {
                    case FacebookAuthProviderID:
                    FBSDKLoginManager().logOut()
                case GoogleAuthProviderID:
                    GIDSignIn.sharedInstance().signOut()
                default:
                    // normal log out
                    try? Auth.auth().signOut()
                    break
                }
            }
        } // */
        
        try? Auth.auth().signOut()
        
        // Printing user info after logging out to ensure logout was successful.
        /*if let providerInfo = Auth.auth().currentUser?.providerData {
            for userInfo in providerInfo {
                print("Still logged into... \(userInfo.providerID) as \(userInfo.displayName)")
            }
            print("Did not log out successfully.")
        } else {
            print("Logged out succesfully!")
        } // */
    }
}

extension UserLoggingHandler {
    
    func updateCurrentUserModels()
    {
        for delegate in delegates {
            delegate.profileChanged()
        }
    }
}
