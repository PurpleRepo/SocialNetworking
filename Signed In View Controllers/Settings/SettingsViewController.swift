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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        profileImageView.viewCorner = profileImageView.frame.height * 0.6
        
        UserLoggingHandler.shared.delegates.append(self)
        profileImageView.image = UserLoggingHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
    }
    
    @IBAction func logOutButtonPressed()
    {
        UserLoggingHandler.shared.signOut()
        if let controller = storyboard?.instantiateViewController(withIdentifier: "EntryPointNavigationController") as? UINavigationController {
            navigationController?.present(controller, animated: false)
        }
    }
}

extension SettingsViewController: UserProfileChangeDelegate {
    
    func profileChanged() {
        profileImageView.image = UserLoggingHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
    }
}
