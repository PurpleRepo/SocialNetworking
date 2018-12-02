//
//  SignUpViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/16/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import TWMessageBarManager
import CoreLocation
import SVProgressHUD

class SignUpViewController: CustomBaseViewController, CLLocationManagerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    
    var setProfileImage = false
    var locationManager = CLLocationManager()
    
    var signUpDispatchGroup = DispatchGroup()
    var dispatchGroupLeaves = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountNameTextField.becomeFirstResponder()
        
        title = "Sign Up"
        
        // HOW TH
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 30 // in meters
        
        
        profileImageView.viewCorner = profileImageView.frame.height * 0.6
        
        let tapper = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SVProgressHUD.show(withStatus: "Getting Location")
        signUpDispatchGroup.enter()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if self.dispatchGroupLeaves == 0 {
                SVProgressHUD.dismiss()
                if self.locationManager.location == nil {
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Could Not Retrieve Location", type: .error)
                }
                self.signUpDispatchGroup.leave()
            }
            self.dispatchGroupLeaves += 1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async()
        {
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Could Not Retrieve Location", type: .error)
            SVProgressHUD.dismiss()
            self.signUpDispatchGroup.leave()
        }
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    // this is where we create a new user.
    func signUp(email: String, password: String, fullName: String)
    {
        var profileImage: UIImage? = nil
        if self.setProfileImage {
            profileImage = self.profileImageView.image! // accessing the User Interface must be done on .main
        }
        signUpDispatchGroup.notify(queue: .global())
        {
            if self.locationManager.location != nil {
                let latitude = String(format: "%f", self.locationManager.location?.coordinate.latitude ?? 37.4220)
                let longitude = String(format: "%f", self.locationManager.location?.coordinate.longitude ?? -122.0841)
                let coordinates = "\(latitude),\(longitude)"
                
                UserLoggingHandler.shared.signUp(email: email, password: password, fullName: fullName, profileImage: profileImage, coordinates: coordinates)
                {
                    (success) in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        if success {
                            self.signIn()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Could Not Sign Up Without Location", type: .error)
                }
            }
        }
    }
    // Move to the HomeSceneViewController, logged in as the current user.
    func signIn()
    {
        performSegue(withIdentifier: "SignedUpSegue", sender: self)
    }
    
    // MARK: - IBActions
    @IBAction func signUpButtonPressed()
    {
        SVProgressHUD.show(withStatus: "Signing Up")
        guard let accountName = accountNameTextField?.text, let password = passwordTextField?.text, let fullName = fullNameTextField.text else {
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: "Field(s) Missing", type: .error)
            return
        }
        signUp(email: accountName, password: password, fullName: fullName)
    }
    
    @IBAction func chooseImageButtonPressed()
    {
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profileImageView.image = image
        setProfileImage = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == accountNameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            fullNameTextField.becomeFirstResponder()
        }
        
        return true
    }
}

