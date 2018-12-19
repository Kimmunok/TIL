//
//  InfoViewController.swift
//  ECommerceSNS
//
//  Created by 김문옥 on 2018. 8. 29..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet var InfoBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        InfoBtn.target = self.revealViewController()
        
        InfoBtn.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
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
