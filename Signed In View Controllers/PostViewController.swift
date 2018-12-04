//
//  PostViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 12/3/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var postImageImageView: UIImageView!
    @IBOutlet weak var postUserProfileImageView: ProfileImageTemplate!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var postLikesLabel: UILabel!
    @IBOutlet weak var postCommentsLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
