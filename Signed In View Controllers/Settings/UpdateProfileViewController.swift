//
//  UpdateProfileViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/26/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import SVProgressHUD
import TWMessageBarManager

class UpdateProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileEmailTextField: UITextField!
    @IBOutlet weak var profileFullNameTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileChanged), name: FirebaseAPIHandler.shared.userProfileChangeNotification, object: nil)
        profileChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.viewCorner = profileImageView.frame.height * 0.6
        
        profileImageView.image = FirebaseAPIHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func profileChanged() {
        DispatchQueue.main.async {
            self.profileImageView.image = FirebaseAPIHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
            self.profileFullNameTextField.text = FirebaseAPIHandler.shared.currentUser?.fullName ?? "User"
        }
    }
    
    @IBAction func chooseImageButtonPressed()
    {
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed()
    {
        if var temporaryUserModel = FirebaseAPIHandler.shared.currentUser, let newName = profileFullNameTextField.text {
            if temporaryUserModel.fullName != newName || temporaryUserModel.profileImage != profileImageView.image {
                SVProgressHUD.show(withStatus: "Saving Changes")
                temporaryUserModel.fullName = newName
                temporaryUserModel.profileImage = profileImageView.image
                FirebaseAPIHandler.shared.updateUserProfile(userModel: temporaryUserModel)
                {
                    () in
                    DispatchQueue.main.async {
                        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Updated Profile!", type: .success)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
}

extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
