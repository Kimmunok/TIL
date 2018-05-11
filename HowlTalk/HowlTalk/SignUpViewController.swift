//
//  SignUpViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 5..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import MaterialComponents

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var color: String!
    var isSelectImage: Bool = false
    
    @IBOutlet weak var emailTextField: YokoTextField!
    @IBOutlet weak var nameTextField: YokoTextField!
    @IBOutlet weak var passwordTextField: YokoTextField!
    @IBOutlet weak var signupButton: MDCRaisedButton!
    @IBOutlet weak var cancelButton: MDCFlatButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        // 상태바 그리기
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
            m.height.equalTo(20)
        }
        color = remoteconfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        signupButton.backgroundColor = UIColor(hex: color)
//        cancelButton.backgroundColor = UIColor(hex: color)
        cancelButton.customTitleColor = UIColor(hex: color)
        
//        signupButton.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        
        // Create a Raised Button
        // See https://material.io/guidelines/what-is-material/elevation-shadows.html
        
        signupButton.setElevation(ShadowElevation(rawValue: 4), for: .normal)
        //        signupButton.setTitle("Tap Me Too", for: .normal)
        signupButton.sizeToFit()
        signupButton.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        self.view.addSubview(signupButton)
        
        // Create a Flat Button
        
        //        cancelButton.setTitle("Tap me", for: .normal)
        cancelButton.sizeToFit()
        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        self.view.addSubview(cancelButton)
        
    }
    
    @objc func imagePicker() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let imageInfo = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("image info error")
            return
        }
        
        imageView.image = imageInfo
        isSelectImage = true
        imageView.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)

    }
    
    @IBAction func pressReturnInEmail(_ sender: Any) {
        
        self.nameTextField.becomeFirstResponder() // 텍스트필드에 포커스
    }
    
    @IBAction func pressReturnInName(_ sender: Any) {
        
        self.passwordTextField.becomeFirstResponder() // 텍스트필드에 포커스
    }
    
    @IBAction func pressReturnInPassword(_ sender: Any) {
        
        self.view.endEditing(true)
        signupEvent()
    }
    
    @objc func signupEvent() {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, err) in
            guard err == nil else {
                print("err.debugDescription : \(err.debugDescription)")
                
                var errMessage = err.debugDescription
                let strArray = err.debugDescription.components(separatedBy: "\"")
                
                // "aaaaaa\"aaaaaaa\"aaaaaaa"
                if strArray.count == 3 {
                    errMessage = strArray[1]
                }

                let alert = UIAlertController(title: "가입 에러", message: errMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (action) in
                    self.emailTextField.text! = ""
                    self.nameTextField.text! = ""
                    self.passwordTextField.text! = ""
                    self.emailTextField.becomeFirstResponder() // 텍스트필드에 포커스
                }))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let uid = user?.uid
            
            if self.isSelectImage == false {
                
                self.imageView.image = #imageLiteral(resourceName: "if_user_male2_172626")
            }
            
            guard let image = UIImageJPEGRepresentation(self.imageView.image!, 0.1) else {
                print("image representation error")
                return
            }
            
            // 유저명을 FCM 서버로 전달
//            user?.createProfileChangeRequest().displayName = self.nameTextField.text!
//            user?.createProfileChangeRequest().commitChanges(completion: nil)
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.nameTextField.text!
            changeRequest?.commitChanges(completion: nil)
            
            Storage.storage().reference().child("userImages").child(uid!).putData(image, metadata: nil, completion: { (data, error) in
                
                if error != nil {
                    print(error.debugDescription)
                    return
                }
                
                let imageUrl = data?.downloadURL()?.absoluteString
                
                // 간편 가입하기의 경우 values의 값
                let values = [
                    "profileImageUrl" : imageUrl,
                    "email" : self.emailTextField.text!,
                    "username" : self.nameTextField.text!,
                    "password" : self.passwordTextField.text!,
                    "uid" : Auth.auth().currentUser?.uid
                ]
                
                Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
                    if err == nil {
                        let alert = UIAlertController(title: "가입 성공", message: "회원가입이 완료되었습니다", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (action) in
                            self.cancelEvent()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            })
        }
    }
    
    @objc func cancelEvent() {
        
        self.dismiss(animated: true, completion: nil)
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
