//
//  ViewController.swift
//  SocialNetworking
//
//  Created by Andrew Bailey on 11/16/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import TWMessageBarManager
import Crashlytics
import Fabric
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import SVProgressHUD

class SignInViewController: CustomBaseViewController, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate
{
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var accountPasswordTextField: UITextField!
    @IBOutlet weak var rememberMeCheckboxButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        accountNameTextField?.becomeFirstResponder()
        title = "Sign In"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        let tapper = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }
    
    // MARK: Google Sign-In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        SVProgressHUD.show(withStatus: "Signing In")
        if error != nil {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FirebaseAPIHandler.shared.signIn(with: credential)
        {
            (success) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if success {
                    self.performSegue(withIdentifier: "SignInSegue", sender: self)
                }
            }
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {}
    
    // MARK: Facebook Sign-In
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        SVProgressHUD.show(withStatus: "Signing In")
        if let error = error {
            //print(error.localizedDescription)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            return
        }
        guard !result.isCancelled, result.grantedPermissions.contains("email") else {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        // code provided by Lokesh
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id,name,birthday,email,first_name,last_name,middle_name,picture.width(4096).height(4096)"])?.start(completionHandler:
        {
            (connection, result, error) in
            if error != nil {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            } else {
                var attributes = Dictionary<String, Any>()
                if let values = result as? Dictionary<String, AnyObject> {
                    attributes["facebook_id"] = values["id"]
                    attributes["last_name"] = values["last_name"]
                    attributes["first_name"] = values["first_name"]
                    attributes["email"] = values["email"]
//                    print("Facebook attributes: \(attributes)")
                }
            }
        })
        FirebaseAPIHandler.shared.signIn(with: credential)
        {
            (success) in
            DispatchQueue.main.async {
                if success {
                    self.performSegue(withIdentifier: "SignInSegue", sender: self)
                }
            }
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) { }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }

    // MARK: - Email & Password Authentication
    // UserLoggingHandler employs an escaping closure so we can perform a segue and clear the password field on success.
    func signIn(email: String, password: String){
        SVProgressHUD.show(withStatus: "Signing In")
        FirebaseAPIHandler.shared.signIn(email: email, password: password) {
            (success) in
            if success == true {
                DispatchQueue.main.async {
                    self.accountPasswordTextField?.text = ""
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "SignInSegue", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func sendPasswordResetEmail(email: String)
    {
        Auth.auth().sendPasswordReset(withEmail: email)
        {
            (error) in
            if error == nil {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Password reset request sent to: \(email)!", type: .success)
            } else {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error?.localizedDescription, type: .error)
            }
        }
    }
}

// MARK: - IBActions
extension SignInViewController {
    
    @IBAction func rememberMeButtonPressed() {
        //if rememberMeCheckboxButton.state ==
    }
    
    @IBAction func signInButtonPressed(){
        guard let accountName = accountNameTextField?.text, let password = accountPasswordTextField?.text else {
            return
        }
        signIn(email: accountName, password: password)
    }
    
    @IBAction func sendPasswordResetEmailButtonPressed()
    {
        guard let accountName = accountNameTextField?.text else {
            return
        }
        sendPasswordResetEmail(email: accountName)
    }
}
