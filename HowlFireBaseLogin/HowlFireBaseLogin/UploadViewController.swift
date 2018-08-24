//
//  UploadViewController.swift
//  HowlFireBaseLogin
//
//  Created by 김문옥 on 2018. 3. 30..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var explaination: UITextField!
    
    @IBAction func uploadButton(_ sender: Any) {
        
        upload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 5.0
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openGallery)))
        imageView.isUserInteractionEnabled = true // 유저 상호작용
    }
    
    @objc func openGallery() {
        
        let imagePick = UIImagePickerController()
        imagePick.delegate = self
        imagePick.allowsEditing = true
        imagePick.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(imagePick, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func upload() {
        
        let image = UIImageJPEGRepresentation(self.imageView.image!, 0.1)
//        let image = UIImagePNGRepresentation(self.imageView.image!)

        let imageName = Auth.auth().currentUser!.uid + "\(Int(NSDate.timeIntervalSinceReferenceDate * 1000)).jpg"
        
        let riversRef = Storage.storage().reference().child("ios_images").child(imageName)
        
        riversRef.putData(image!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print(error?.localizedDescription)
                print(error.debugDescription)
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            if let downloadURL = metadata.downloadURL()?.absoluteString {
                Database.database().reference().child("users").childByAutoId().setValue([
                    "userId": Auth.auth().currentUser?.email,
                    "uid": Auth.auth().currentUser?.uid,
                    "subject": self.subject.text!,
                    "explaination": self.explaination.text!,
                    "imageUrl": downloadURL,
                    "imageName": imageName
                    ])
                self.dismiss(animated: true, completion: nil)
            }
        }
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
