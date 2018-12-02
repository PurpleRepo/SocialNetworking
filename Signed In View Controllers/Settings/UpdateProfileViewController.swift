//
//  UpdateProfileViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/26/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import SVProgressHUD

class UpdateProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.viewCorner = profileImageView.frame.height * 0.6
        
        profileImageView.image = UserLoggingHandler.shared.currentUser?.profileImage ?? UIImage(named: "defaultProfileImage")
    }
    
    @IBAction func chooseImageButtonPressed()
    {
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed()
    {
//        MBProgressHUD.showAdded(to: view, animated: true)
        SVProgressHUD.show(withStatus: "Saving Changes")
        StorageHandler.shared.updateImage(folder: StorageHandler.shared.folders.userImageFolder, id: (UserLoggingHandler.shared.currentUser?.id)!, replacement: profileImageView.image ?? UIImage(named: "defaultProfileImage")!)
        {
            (success) in
//            MBProgressHUD.hide(for: self.view, animated: true)
            SVProgressHUD.dismiss()
            UserLoggingHandler.shared.currentUser?.profileImage = self.profileImageView.image
        }
    }
}

extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profileImageView.image = image
        /*StorageHandler.shared.updateImage(replacement: image)
        {
            (success) in
            UserLoggingHandler.shared.currentUser?.profileImage = image
        } // */
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
