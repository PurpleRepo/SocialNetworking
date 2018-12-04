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
import Crashlytics

extension FirebaseAPIHandler {
    
    // TODO: Need to include storing storage references
    func signIn(email: String, password: String, completion: @escaping (Bool) -> ())
    {
        Auth.auth().signIn(withEmail: email, password: password)
        {
            (result, error) in
            if error == nil {
                guard let user = result?.user else {
                    completion(false)
                    return
                }
                FirebaseAPIHandler.shared.fetchUser(userID: user.uid)
                {
                    (userModel) in
                    self.currentUser = userModel
                    self.logUser()
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Successfully signed in!", type: .success)
                    completion(true)
                }
            } else {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error?.localizedDescription, type: .error)
                completion(false)
            }
        }
    }
    
    // Google & Facebook Sign In
    func signIn(with credential: AuthCredential, completion: @escaping (Bool) -> ())
    {
        Auth.auth().signInAndRetrieveData(with: credential)
        {
            (authResult, error) in
            if error == nil {
                guard let user = authResult?.user else { return }
                FirebaseAPIHandler.shared.fetchUser(userID: user.uid)
                {
                    (userModel) in
                    self.currentUser = userModel
                    self.logUser()
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
    
    func logUser() {
        Crashlytics.sharedInstance().setUserEmail(currentUser?.email)
        Crashlytics.sharedInstance().setUserIdentifier(currentUser?.id)
        Crashlytics.sharedInstance().setUserName(currentUser?.fullName)
    }
}
