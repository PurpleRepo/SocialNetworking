//
//  StorageHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/27/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import TWMessageBarManager

class StorageHandler {
    
    static let shared = StorageHandler()
    
    var storageReference: StorageReference!
    
    let folders = (userImageFolder: "USERIMAGES",
                   postImageFolder: "POSTIMAGES")
    
    private init(){
        storageReference = Storage.storage().reference()
    }
    
    // MARK: - Image Uploading/Downloading
    func uploadImage(folder: String, id: String, image: UIImage, completion: @escaping (Bool) -> ())
    {
        let data = image.jpeg(UIImage.JPEGQuality.lowest)
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
//        let id = Auth.auth().currentUser?.uid
        let imageName = "\(id).png"
        storageReference.child(folder).child(imageName).putData(data!, metadata: metadata)
        {
            (metadataStored, error) in
            if error == nil {
                completion(true)
            } else {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error?.localizedDescription, type: .error)
                completion(false)
            }
        }
    }
    func pullImage(folder: String, id: String, completion: @escaping (UIImage?) -> ())
    {
        let imageReference = storageReference.child(folder).child("\(id).png")
        imageReference.getData(maxSize: 1 * 1024 * 1024)
        {
            (data, error) in
            if error == nil {
                completion(UIImage(data: data!))
            } else {
                completion(nil)
            }
        }
    }
    
    func updateImage(folder: String, id: String, replacement: UIImage, completion: @escaping (Bool) -> ())
    {
        self.uploadImage(folder: folder, id: id, image: replacement)
        {
            (success) in
            UserLoggingHandler.shared.currentUser?.profileImage = replacement
            UserLoggingHandler.shared.updateCurrentUserModels()
            completion(success)
        }
    }
    
    func deleteImage(folder: String, id: String, completion: @escaping () -> ())
    {
        let imageReference = storageReference.child(folder).child("\(id).png")
        imageReference.delete { (error) in }
    }
}
