//
//  UsersViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/20/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import SVProgressHUD

class UsersViewController: CustomBaseViewController {

    @IBOutlet weak var usersListTableView: UITableView!
    
    var dataSource_usersList_original = Array<UserModel>()
    var dataSource_usersList_current = Array<UserModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Users"
        
        SVProgressHUD.show(withStatus: "Loading Users List")
        DispatchQueue.global().async {
            
            DatabaseHandler.shared.fetchUserList(){
                (userModelArray) in
                if var unwrappedUserModelArray = userModelArray {
                    unwrappedUserModelArray.removeAll(where: { $0.id == UserLoggingHandler.shared.currentUser?.id })
                    self.dataSource_usersList_original = unwrappedUserModelArray
                    self.dataSource_usersList_current = self.dataSource_usersList_original
                    
                    DispatchQueue.main.async {
                        self.usersListTableView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowGoogleMaps" {
            if let destination = segue.destination as? UsersLocationViewController {
                destination.userModels = dataSource_usersList_original
            }
        }
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(dataSource_usersList_current.count)
        return dataSource_usersList_current.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as! UserTableViewCell
        
        cell.tag = indexPath.row
        if dataSource_usersList_current[indexPath.row].profileImage != nil {
            cell.userAvatarPhotoImageView.image = dataSource_usersList_current[indexPath.row].profileImage
        }
        cell.fullNameLabel.text = dataSource_usersList_current[indexPath.row].fullName
        
        cell.friendButton.addTarget(self, action: #selector(friendButtonPressed), for: .touchUpInside)
        cell.dismissButton.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    @objc func friendButtonPressed(sender: UIButton)
    {
        print("Pressed friend request button!")
        if let currentUserID = UserLoggingHandler.shared.currentUser?.id {
            DatabaseHandler.shared.addFriend(for: currentUserID, friendID: dataSource_usersList_current[sender.tag].id)
            {
                (success) in
                // TODO: Must finish!
            }
        }
        // remove from original & remove from current
        // reloadData
    }
    
    @objc func dismissButtonPressed(sender: UIButton)
    {
        // TODO: Must finish!
        print("Pressed dismiss button!")
        // remove from original & remove from current
        // reloadData
    }
}
