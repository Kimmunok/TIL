//
//  ViewController.swift
//  HowlFireBaseLogin
//
//  Created by 김문옥 on 2018. 3. 28..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import Crashlytics

class ViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["email"]
        
        Auth.auth().addStateDidChangeListener({ (user, err) in
                if user != nil {
                self.performSegue(withIdentifier: "Home", sender: nil)
            }
        })
        
        // 강제 비정상 종료 구현 테스트
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)

    }
    
    // 강제 비정상 종료 구현 테스트
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
    
    @IBAction func signIn(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func emailSignIn(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            
            
            if(error != nil){
                
                Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                    // ...
                }
                
            }else{
                
                let alert = UIAlertController(title: "알림", message: "회원가입완료", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult?, error: Error!) {
        if(result?.token == nil){
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                return
            }
        }
        FBSDKLoginManager().logOut();
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

