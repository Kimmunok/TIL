//
//  ViewController.swift
//  HowlDynamicLinks
//
//  Created by 김문옥 on 2018. 4. 3..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let components = DynamicLinkComponents(link: URL(string: "https://www.naver.com")!, domain: "q94qu.app.goo.gl")
        let iOSParams = DynamicLinkIOSParameters(bundleID: "HelloWorld.Munok.HowlDynamicLinks")
        iOSParams.appStoreID = "585027354"
        
        components.iOSParameters = iOSParams
        print(components.url?.absoluteURL)
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .short
        components.options = options
        
        components.shorten { (url, warning, err) in
            print(url)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

