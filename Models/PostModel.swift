//
//  Post.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/27/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

// Create Post model
// Generate a Post ID
// Create UserPost model

import Foundation
import UIKit
                                        // Dev. Comments        | Fetching          | Uploading         | Stored ? Instance
                                        // ---------------------|-------------------|-------------------|-------------------
struct UserPost {                       //                      |                   |                   |
    var postID: String?                 //......................|...................|...................| Both
    var post: Post                      //                      |                   |                   |
}                                       //                      |                   |                   |
                                        // ---------------------|-------------------|-------------------|-------------------
struct Post {                           //                      | via UserPost's ID | (POSTS) Database  |
    var userID: String //...............//......................| to get user Image |...................| Stored (Reference To Get UserImage. Also In Case User Is Deleted, This Can Be Cleaned Up)
    var postingUserName: String         //                      |                   |                   | Both
    var description: String //..........//......................|...................|...................| Both
    var creationTimestamp: Double       //                      |                   |                   | Both
    var postImage: UIImage //...........//......................|...................| (IMAGES) Storage  | Both
    var userImage: UIImage //...........//......................|...................|...................| Instance (Stored By Other Class)
    var wasLikedByUser: Bool            // whenViewedBy others  |                   |                   | Instance (likedBy.contains(user))
    var likes: Int //...................//......................|...................|...................| Instance (likedBy.count)
    var likedBy: [String]               // userID array         |                   |                   | Both
    var commentsBy: [String: String]    // userID: comment      |                   |                   | Both
}
