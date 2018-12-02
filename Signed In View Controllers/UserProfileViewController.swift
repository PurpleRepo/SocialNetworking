//
//  UserProfileViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 12/1/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var userModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return UICollectionViewCell()
    }
}
