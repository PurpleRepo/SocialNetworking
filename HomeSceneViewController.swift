//
//  HomeSceneViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/16/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import TWMessageBarManager

class HomeSceneViewController: CustomBaseViewController {
    
    var user: User?
    
    @IBOutlet weak var welcomeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let unwrappedUser = Auth.auth().currentUser {
            user = unwrappedUser
            welcomeLabel.text = String(format: "Welcome, %@!", user?.displayName ?? "user")
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    @IBAction func signOutButtonPressed(){
        signOut()
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Logged out.", description: "Logged out succesfully.", type: .success)
        performSegue(withIdentifier: "SignOutSegue", sender: self)
    }
}
