//
//  FriendsViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/20/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import SVProgressHUD

class FriendsViewController: CustomBaseViewController {

    @IBOutlet weak var friendsListTableView: UITableView!
    
    var dataSource_friendsList_original = Array<UserModel>()
    var dataSource_friendsList_current = Array<UserModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Friends"
        
        SVProgressHUD.show(withStatus: "Loading Friends List")
//        MBProgressHUD.showAdded(to: view, animated: true)
        // load data
        DispatchQueue.global().async {
            
            // dataSource_usersList_original = ...
            self.dataSource_friendsList_current = self.dataSource_friendsList_original
            
            DispatchQueue.main.async {
                self.friendsListTableView.reloadData()
//                MBProgressHUD.hide(for: self.view, animated: true)
                SVProgressHUD.dismiss()
            }
        }
    }
}

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource_friendsList_original.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell") as! FriendTableViewCell
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
            controller.userModel = dataSource_friendsList_current[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
 // */
