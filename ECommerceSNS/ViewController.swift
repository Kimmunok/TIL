//
//  ViewController.swift
//  ECommerceSNS
//
//  Created by 김문옥 on 2018. 8. 23..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {


    @IBAction func signIn(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 델리게이트 붙이는 부분
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

