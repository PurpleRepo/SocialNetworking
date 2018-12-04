//
//  AccountViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/20/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SettingsViewController: CustomBaseViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileChanged), name: FirebaseAPIHandler.shared.userProfileChangeNotification, object: nil)
        profileChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        profileImageView.viewCorner = profileImageView.frame.height * 0.6
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func logOutButtonPressed()
    {
        FirebaseAPIHandler.shared.signOut()
        if let controller = storyboard?.instantiateViewController(withIdentifier: "EntryPointNavigationController") as? UINavigationController {
            navigationController?.present(controller, animated: false)
        }
    }
    
    @objc func profileChanged() {
        DispatchQueue.main.async {
            self.profileImageView.image = FirebaseAPIHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
        }
    }
}
