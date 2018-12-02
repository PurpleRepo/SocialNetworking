//
//  PostDatabaseHandler.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/29/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation
import UIKit

extension FirebaseAPIHandler {
    
    // MARK: - Upload / Delete
    func uploadPost(post: Post, completion: @escaping (UserPost?) -> ())
    {
        var userPost = UserPost(postID: nil, post: post)
        guard let postID = databaseReference.child(FirebaseAPIHandler.databaseFolders.postsFolder).childByAutoId().key else {
            completion(nil)
            return
        }
        userPost.postID = postID
        var successes = [false, false, false]
        
        let postUploadingGroup = DispatchGroup()
        postUploadingGroup.enter()
        FirebaseAPIHandler.shared.uploadImage(folder: FirebaseAPIHandler.storageFolders.postImagesFolder, id: postID, image: post.postImage)
        {
            (success) in
            successes[0] = success
            postUploadingGroup.leave()
        }
        
        postUploadingGroup.enter()
        databaseReference.child(FirebaseAPIHandler.databaseFolders.postsFolder).child(postID).setValue(["UserID": post.userID,
                                                                                                        "PostingUserName": post.postingUserName,
                                                                                                        "Description": post.description,
                                                                                                        "CreationTimestamp": post.creationTimestamp,
                                                                                                        "LikedBy": post.likedBy,
                                                                                                        "CommentsBy": post.commentsBy])
        {
            (error, ref) in
            if error == nil {
                successes[1] = true
            }
            postUploadingGroup.leave()
        }
        
        postUploadingGroup.enter()
        databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).child(post.userID).observeSingleEvent(of: .value)
        {
            (snapshot) in
            guard let informationDictionary = snapshot.value as? [String: Any] else {
                postUploadingGroup.leave()
                return
            }
            var postsArray = Array<String>()
            if let fetchedPosts = informationDictionary["Posts"] as? Array<String> {
                postsArray = fetchedPosts
            }
            postsArray.append(postID)
            self.databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).child(post.userID).updateChildValues(["Posts": postsArray])
            {
                (error, ref) in
                if error == nil {
                    successes[2] = true
                }
                postUploadingGroup.leave()
            }
        }
        
        postUploadingGroup.notify(queue: .global())
        {
            var failedAStep = false
            for i in 0..<successes.count {
                if successes[i] == false {
                    failedAStep = true
                }
            }
            if !failedAStep {
                completion(userPost)
            } else {
                self.deletePost(userPost: userPost)
                {
                    () in
                    completion(nil)
                }
            }
        }
    }
    
    func deletePost(userPost: UserPost, completion: @escaping () -> ())
    {
        let postDeletingGroup = DispatchGroup()
        postDeletingGroup.enter()
        self.deleteImage(folder: FirebaseAPIHandler.storageFolders.postImagesFolder, id: userPost.postID!)
        {
            () in
            postDeletingGroup.leave()
        }
        
        postDeletingGroup.enter()
        databaseReference.child(FirebaseAPIHandler.databaseFolders.postsFolder).child(userPost.postID!).removeValue()
        {
            (error, ref) in
            postDeletingGroup.leave()
        }
        
        postDeletingGroup.enter()
        databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).child(userPost.post.userID).observeSingleEvent(of: .value)
        {
            (snapshot) in
            guard let informationDictionary = snapshot.value as? [String: Any] else {
                postDeletingGroup.leave()
                return
            }
            if var fetchedPosts = informationDictionary["Posts"] as? Array<String> {
                fetchedPosts.removeAll(where: {$0 == userPost.postID})
                self.databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).child(userPost.post.userID).updateChildValues(["Posts": fetchedPosts])
                {
                    (error, ref) in
                    postDeletingGroup.leave()
                }
            } else {
                postDeletingGroup.leave()
            }
        }
        
        postDeletingGroup.notify(queue: .global())
        {
            completion()
        }
    }
    
    // MARK: - Fetching
    func fetchPost(userID: String, postID: String, completion: @escaping (Post?) -> ())
    {
        databaseReference.child(FirebaseAPIHandler.databaseFolders.postsFolder).child(postID).observeSingleEvent(of: .value)
        {
            (snapshot) in
            guard let postInformation = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            guard let userID = postInformation["UserID"] as? String, let postingUserName = postInformation["PostingUserName"] as? String, let description = postInformation["Description"] as? String, let creationTimestamp = postInformation["CreationTimeStamp"] as? Double else {
                completion(nil)
                return
            }
            
            var likedBy = Array<String>()
            var commentsBy = [String:String]()
            if let fetchedLikedBy = postInformation["LikedBy"] as? Array<String> {
                likedBy = fetchedLikedBy
            }
            if let fetchedCommentsBy = postInformation["CommentsBy"] as? [String: String] {
                commentsBy = fetchedCommentsBy
            }
            
            let fetchPostDispatchGroup = DispatchGroup()
            
            var postImage: UIImage?
            fetchPostDispatchGroup.enter()
            self.fetchImage(folder: FirebaseAPIHandler.storageFolders.postImagesFolder, id: postID)
            {
                (image) in
                postImage = image
                fetchPostDispatchGroup.leave()
            }
            
            var userImage: UIImage?
            fetchPostDispatchGroup.enter()
            self.fetchImage(folder: FirebaseAPIHandler.storageFolders.userImagesFolder, id: userID)
            {
                (image) in
                userImage = image
                fetchPostDispatchGroup.leave()
            }
            
            fetchPostDispatchGroup.notify(queue: .global())
            {
                var wasLikedByUser = false
                if let currentUserID = FirebaseAPIHandler.shared.currentUser?.id {
                    if likedBy.contains(currentUserID) {
                        wasLikedByUser = true
                    }
                }
                let likes = likedBy.count
                
                guard let postImage = postImage else {
                    completion(nil)
                    return
                }
                let post = Post.init(userID: userID, postingUserName: postingUserName, description: description, creationTimestamp: creationTimestamp, postImage: postImage, userImage: userImage ?? UIImage(named: "defaultProfileImage")!, wasLikedByUser: wasLikedByUser, likes: likes, likedBy: likedBy, commentsBy: commentsBy)
                completion(post)
            }
        }
    }
    
    // can return an empty array
    func fetchPostsByUser(userID: String, completion: @escaping (Array<UserPost>?) -> ())
    {
        databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).child(userID).observeSingleEvent(of: .value)
        {
            (snapshot) in
            
            guard let userInformation = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            if let postIDArray = userInformation["Posts"] as? Array<String> {
                
                var postModels = Array<UserPost>()
                let postFetchingDispatchGroup = DispatchGroup()
                
                for postID in postIDArray {
                    postFetchingDispatchGroup.enter()
                    self.fetchPost(userID: userID, postID: postID)
                    {
                        (post) in
                        if let post = post {
                            objc_sync_enter(postModels)
                            postModels.append(UserPost(postID: userID, post: post))
                            objc_sync_exit(postModels)
                        }
                        postFetchingDispatchGroup.leave()
                    }
                }
                
                postFetchingDispatchGroup.notify(queue: .global())
                {
                    completion(postModels)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchAllPosts(completion: @escaping (Array<UserPost>?) -> ())
    {
        databaseReference.child(FirebaseAPIHandler.databaseFolders.usersFolder).observeSingleEvent(of: .value)
        {
            (snapshot) in
            
            guard let users = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            var userPostModels = Array<UserPost>()
            let userPostFetchingDispatchGroup = DispatchGroup()
            
            for user in users {
                userPostFetchingDispatchGroup.enter()
                self.fetchPostsByUser(userID: user.key)
                {
                    (userPosts) in
                    
                    if let userPosts = userPosts {
                        objc_sync_enter(userPostModels)
                        userPostModels.append(contentsOf: userPosts)
                        objc_sync_exit(userPostModels)
                    }
                    userPostFetchingDispatchGroup.leave()
                }
            }
            
            userPostFetchingDispatchGroup.notify(queue: .global())
            {
                completion(userPostModels)
            }
        }
    }
}
