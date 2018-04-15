//
//  LoginViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 5..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import MaterialComponents

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: YokoTextField!
    @IBOutlet weak var passwordTextField: YokoTextField!
    @IBOutlet weak var loginButton: MDCRaisedButton!
    @IBOutlet weak var signinButton: MDCFlatButton!
    let remoteconfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 상태바 그리기
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
            
            // iPhone X 판별
            if UIScreen.main.nativeBounds.height == 2436 {
                
                m.height.equalTo(40)
            } else {
                
                m.height.equalTo(20)
            }
            
            
        }
        color = remoteconfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
//        signinButton.backgroundColor = UIColor(hex: color)
        signinButton.customTitleColor = UIColor(hex: color)

//
//        signinButton.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        
        
        // Create a Raised Button
        // See https://material.io/guidelines/what-is-material/elevation-shadows.html
        
        loginButton.setElevation(ShadowElevation(rawValue: 4), for: .normal)
//        loginButton.setTitle("Tap Me Too", for: .normal)
        loginButton.sizeToFit()
        loginButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        self.view.addSubview(loginButton)
        
        // Create a Flat Button
        
//        signinButton.setTitle("Tap me", for: .normal)
        signinButton.sizeToFit()
        signinButton.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        self.view.addSubview(signinButton)
        
//        try! Auth.auth().signOut()
        
        // 로그인 된 상태라면 메인뷰로 화면을 넘긴다
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                if let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as? UITabBarController {

                    self.present(view, animated: true, completion: nil)
                }
                
                // 토큰 생성
                let uid = Auth.auth().currentUser?.uid
                
                if let token = InstanceID.instanceID().token() {
                    
                    Database.database().reference().child("users").child(uid!).updateChildValues(["pushToken" : token])
                }
            }
        }
    }

    @IBAction func pressReturnInEmail(_ sender: Any) {
        
        self.passwordTextField.becomeFirstResponder() // 텍스트필드에 포커스
    }
    @IBAction func pressReturnInpassword(_ sender: Any) {
        
        self.view.endEditing(true)
        loginEvent()
    }
    
    
    @objc func loginEvent() {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, err) in
            
            guard err == nil else {
                print(err.debugDescription)
                
                var errMessage = err.debugDescription
                let strArray = err.debugDescription.components(separatedBy: "\"")
                
                // "aaaaaa\"aaaaaaa\"aaaaaaa"
                if strArray.count == 3 {
                    errMessage = strArray[1]
                }
                
                let alert = UIAlertController(title: "로그인 에러", message: errMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (action) in
                    self.emailTextField.text! = ""
                    self.passwordTextField.text! = ""
                    self.emailTextField.becomeFirstResponder() // 텍스트필드에 포커스
                }))
                
                self.present(alert, animated: true, completion: nil)

                return
            }
        }
    }
    
    @objc func presentSignup() {
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignUpViewController
        self.present(view, animated: true, completion: nil)
    }
    
    // 빈곳을 터치하면 키보드나 데이트피커 등을 숨긴다
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
