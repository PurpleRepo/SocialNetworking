//
//  PostTableViewCell.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 12/3/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postUserProfileImageImageView: ProfileImageTemplate!
    @IBOutlet weak var postUserProfileNameLabel: UILabel!
    @IBOutlet weak var postImageImageView: UIImageView!
    @IBOutlet weak var postUserLocationLabel: UILabel!
    @IBOutlet weak var postCreationTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func likeButtonPressed()
    {
        
    }
    @IBAction func commentButtonPressed()
    {
        
    }
}
