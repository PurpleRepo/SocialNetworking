//
//  UsersLocationViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/29/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import GoogleMaps

let zoomInRect: CGRect = CGRect(x: 0, y: 0, width: 80, height: 80)
let zoomOutRect: CGRect = CGRect(x: 0, y: 0, width: 40, height: 40)

class UsersLocationViewController: CustomBaseViewController, GMSMapViewDelegate {

    @IBOutlet weak var googleMapsView: GMSMapView!
    
    var userModels: Array<UserModel>?
    
    var selectedMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //title = "Users Locations"
        
        googleMapsView.mapType = .satellite
        
        guard let userModels = userModels else {
            return
        }
        loadUsersOntoMap(users: userModels)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let marker = selectedMarker {
            marker.iconView!.frame = zoomOutRect
            marker.iconView!.layer.cornerRadius = 40/2
            marker.iconView!.layer.masksToBounds = false
            marker.iconView!.clipsToBounds = true
        }
        if let ImageView = marker.iconView as? UIImageView{
            selectedMarker = marker
            ImageView.frame = zoomInRect
            ImageView.layer.cornerRadius = 80/2
            ImageView.layer.masksToBounds = false
            ImageView.clipsToBounds = true
            self.googleMapsView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
            
        }
        
        return true
    }
    
    func loadUsersOntoMap(users: Array<UserModel>)
    {
        for user in users {
            createMarker(userName: user.fullName ?? "N/A", profileImage: user.profileImage ?? UIImage(named: "defaultProfileImage")!, latitude: user.latitude, longitude: user.longitude)
        }
    }
    
    func createMarker(userName: String, profileImage: UIImage, latitude: Double, longitude: Double)
    {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let marker = GMSMarker()
        
        marker.position = location.coordinate
        marker.title = userName
        
        // create a custom view for the marker - rounded
        //var aView = UIImageView
        
        //let smallProfileImage = profileImage.resizeimage(image: profileImage, withSize: CGSize(width: 50, height: 50))
        
        //marker.icon = smallProfileImage
        
        let imgView = UIImageView(frame: zoomOutRect)
        imgView.layer.borderWidth = 2
        imgView.layer.borderColor = UIColor.orange.cgColor
        imgView.layer.cornerRadius = imgView.frame.height/2
        imgView.layer.masksToBounds = false
        imgView.clipsToBounds = true
        imgView.image = profileImage
        marker.iconView = imgView
        
        marker.map = googleMapsView
        
        googleMapsView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 20)
    }
}
