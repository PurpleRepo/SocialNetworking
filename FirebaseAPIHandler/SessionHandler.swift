//
//  SessionHandler.swift
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
        try? Auth.auth().signOut()
    }
    
    func updateCurrentUserModels()
    {
//        for delegate in delegates {
//            delegate.profileChanged()
//        }
    }
}
