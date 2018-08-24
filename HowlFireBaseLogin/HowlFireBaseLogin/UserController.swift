//
//  UserController.swift
//  HowlFireBaseLogin
//
//  Created by 김문옥 on 2018. 3. 29..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase

class UserController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBAction func logout(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
        dismiss(animated: true, completion: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
