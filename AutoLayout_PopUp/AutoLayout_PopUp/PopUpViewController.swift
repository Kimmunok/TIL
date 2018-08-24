//
//  PopUpViewController.swift
//  AutoLayout_PopUp
//
//  Created by 김문옥 on 2018. 3. 11..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var popupImageView: UIImageView!
    @IBOutlet weak var popupHeight: NSLayoutConstraint!
    @IBOutlet weak var popupCenterY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        popupCenterY.constant = 1000
        
        // popupImageView.image?.size.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let ratio = (popupImageView.image?.size.width)! / popupImageView.frame.size.width
//        let calcHeight = (popupImageView.image?.size.height)! / ratio
//        popupHeight.constant = calcHeight
        
        popupCenterY.constant = 0
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        let ratio = (popupImageView.image?.size.width)! / popupImageView.frame.size.width
        let calcHeight = (popupImageView.image?.size.height)! / ratio
        popupHeight.constant = calcHeight

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
