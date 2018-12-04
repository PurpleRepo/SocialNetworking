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
    
    @IBOutlet weak var postsListTableView: UITableView!
    
    var tableView_dataSource_posts = Array<UserPost>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileChanged), name: FirebaseAPIHandler.shared.userProfileChangeNotification, object: nil)
        profileChanged()
        
        // retrieve posts by all users / friends
        
        //DispatchQueue.global(qos)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        
        profileImageView.viewCorner = profileImageView.frame.height * 0.6
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func profileChanged() {
        DispatchQueue.main.async {
            self.profileImageView.image = FirebaseAPIHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
            self.userNameLabel.text = "Welcome, \(FirebaseAPIHandler.shared.currentUser?.fullName ?? "User")!"
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView_dataSource_posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        
        
        return cell
    }
}
