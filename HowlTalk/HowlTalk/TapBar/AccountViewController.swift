//
//  AccountViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 15..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class AccountViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var conditionsCommentLabel: UILabel!
    @IBOutlet weak var conditionsCommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myUid = Auth.auth().currentUser?.uid
        
        // DB 내 정보 불러오기
        Database.database().reference().child("users").child(myUid!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            let url = URL(string: postDict["profileImageUrl"] as! String)
            
            self.imageView.layer.cornerRadius = 125 / 2
            self.imageView.clipsToBounds = true
            self.imageView.kf.setImage(with: url)
            
            self.conditionsCommentLabel.text = postDict["comment"] as? String
            
//            self.array.removeAll()
//
//
//
//            for child in snapshot.children {
//
//                let fchild = child as! DataSnapshot
//                let usermodel = UserModel()
//
//                if let dictionary = fchild.value as? [String : Any] {
//                    usermodel.setValuesForKeys(dictionary)
//
//                    if usermodel.uid == myUid { // 내 정보는 목록에 보이지 않게 건너뛴다
//                        continue
//                    }
//
//                    self.array.append(usermodel)
//                }
//            }
//
//            DispatchQueue.main.async {
//                self.tableview.reloadData()
//            }
        })

        profileImageButton.addTarget(self, action: #selector(imagePicker), for: .touchUpInside)
        
        conditionsCommentButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        self.imageView.image = imageInfo
        self.imageView.contentMode = .scaleAspectFill
        
        guard let image = UIImageJPEGRepresentation(self.imageView.image!, 0.1) else {
            print("image representation error")
            return
        }
        
        let uid = Auth.auth().currentUser?.uid
        
        Storage.storage().reference().child("userImages").child(uid!).putData(image, metadata: nil, completion: { (data, error) in
            
            if error != nil {
                print(error.debugDescription)
                return
            }

            let imageUrl = data?.downloadURL()?.absoluteString
            
            let dic = ["profileImageUrl" : imageUrl]
            
            Database.database().reference().child("users").child(uid!).updateChildValues(dic)
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func showAlert() {
        
        let alertController = UIAlertController(title: "상태 메시지", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textfield) in
            
            textfield.placeholder = "상태메시지를 입력해주세요."
        }
        
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            
            if let textfield = alertController.textFields?.first {
                
                let dic = ["comment" : textfield.text!]
                let uid = Auth.auth().currentUser?.uid
                
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
                
                self.conditionsCommentLabel.text = textfield.text!
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
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
