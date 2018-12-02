//
//  AddPostViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/27/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import SVProgressHUD
import TWMessageBarManager

class AddPostViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var postDescriptionTextView: UITextView!
    @IBOutlet weak var postImageImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ADD POST"
    }
    
    
    @IBAction func uploadImageButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        // #1 validate all fields 
        guard let image = postImageImageView.image, let description = postDescriptionTextView.text else {
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Missing Post Image or Description", type: .error)
            return
        }
        guard let currentUser = FirebaseAPIHandler.shared.currentUser else {
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Not Signed In", type: .error)
            return
        }
        
        // get timestamp
        SVProgressHUD.show(withStatus: "Uploading Post")
        let timestamp = NSDate().timeIntervalSince1970
        
        let post = Post.init(userID: currentUser.id, postingUserName: currentUser.fullName ?? "User", description: description, creationTimestamp: timestamp, postImage: image, userImage: currentUser.profileImage ?? UIImage(named: "defaultProfileImage")!, wasLikedByUser: false, likes: 0, likedBy: Array<String>(), commentsBy: [String : String]())
        
        FirebaseAPIHandler.shared.uploadPost(post: post)
        {
            (userPost) in
            
            DispatchQueue.main.async {
                if userPost != nil {
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Uploaded Post!", type: .success)
                }
                SVProgressHUD.dismiss()
                self.unwindToHomeViewController()
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton){
        unwindToHomeViewController()
    }
    
    func unwindToHomeViewController(){
        performSegue(withIdentifier: "UnwindToTabBarControllerSegue", sender: self)
    }
}

extension AddPostViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        postImageImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
