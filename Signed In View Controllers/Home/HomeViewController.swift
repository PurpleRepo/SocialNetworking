//
//  HomeViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/20/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit

class HomeViewController: CustomBaseViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserLoggingHandler.shared.delegates.append(self)
        
        profileImageView.image = UserLoggingHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
        userNameLabel.text = "Welcome, \(UserLoggingHandler.shared.currentUser?.fullName ?? "User")!"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        
        profileImageView.viewCorner = profileImageView.frame.height * 0.6
    }
}

extension HomeViewController: UserProfileChangeDelegate {
    
    func profileChanged() {
        profileImageView.image = UserLoggingHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
        userNameLabel.text = "Welcome, \(UserLoggingHandler.shared.currentUser?.fullName ?? "User")!"
    }
}
