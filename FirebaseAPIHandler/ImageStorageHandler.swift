//
//  ImageStorageHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/29/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import TWMessageBarManager

extension FirebaseAPIHandler {
    
    func uploadImage(folder: String, id: String, image: UIImage, completion: @escaping (Bool) -> ())
    {
        let data = image.jpeg(UIImage.JPEGQuality.lowest)
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
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
    func fetchImage(folder: String, id: String, completion: @escaping (UIImage?) -> ())
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
            self.currentUser?.profileImage = replacement
            self.updateCurrentUserModelReferences()
            completion(success)
        }
    }
    
    func deleteImage(folder: String, id: String, completion: @escaping () -> ())
    {
        let imageReference = storageReference.child(folder).child("\(id).png")
        imageReference.delete { (error) in }
    }
}
