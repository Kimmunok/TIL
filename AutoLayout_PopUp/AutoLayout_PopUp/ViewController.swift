//
//  ViewController.swift
//  AutoLayout_PopUp
//
//  Created by 김문옥 on 2018. 3. 11..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showPopUp(_ sender: Any) {
        let popupVC: PopUpViewController = UIStoryboard(name: "PopUp", bundle: nil).instantiateViewController(withIdentifier: "popupVC") as! PopUpViewController
        
        popupVC.modalPresentationStyle = .overCurrentContext // 모달창 배경 보이게 해줌
        
        self.present(popupVC, animated: false) {  }
    }
    
}

