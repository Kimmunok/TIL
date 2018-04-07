//
//  ViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 3. 28..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {

    var box = UIImageView()
    var remoteConfig: RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 샘플은 우선 원격 구성 개체 인스턴스를 가져오고 캐시를 빈번하게 새로고칠 수 있도록 개발자 모드를 사용 설정합니다.
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        // TimeInterval is set to expirationDuration here, indicating the next fetch request will use
        // data fetched from the Remote Config service, rather than cached parameter values, if cached
        // parameter values are more than expirationDuration seconds old. See Best Practices in the
        // README for more information.
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
        
        self.view.addSubview(box)
        box.snp.makeConstraints{ (make) in
            make.center.equalTo(self.view)
            make.width.height.equalTo(100)
        }
        box.image = #imageLiteral(resourceName: "loading_icon")
    }
    
    func displayWelcome() {
    
        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if caps {
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(loginVC, animated: false, completion: nil)
        }
        
        self.view.backgroundColor = UIColor(hex: color!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        
        scanner.scanLocation = 1
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

// SWIFT 4
//
//extension UIColor {
//    convenience init(hexString: String, alpha: CGFloat = 1.0) {
//        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        let scanner = Scanner(string: hexString)
//        if (hexString.hasPrefix("#")) {
//            scanner.scanLocation = 1
//        }
//        var color: UInt32 = 0
//        scanner.scanHexInt32(&color)
//        let mask = 0x000000FF
//        let r = Int(color >> 16) & mask
//        let g = Int(color >> 8) & mask
//        let b = Int(color) & mask
//        let red   = CGFloat(r) / 255.0
//        let green = CGFloat(g) / 255.0
//        let blue  = CGFloat(b) / 255.0
//        self.init(red:red, green:green, blue:blue, alpha:alpha)
//    }
//}


