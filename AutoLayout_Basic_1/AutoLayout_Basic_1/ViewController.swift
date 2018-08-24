//
//  ViewController.swift
//  AutoLayout_Basic_1
//
//  Created by 김문옥 on 2018. 3. 4..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func changeMultiplier (changeMultiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(item: self.firstItem,
                                               attribute: self.firstAttribute,
                                               relatedBy: self.relation,
                                               toItem: self.secondItem,
                                               attribute: self.secondAttribute,
                                               multiplier: changeMultiplier,
                                               constant: self.constant)
        newConstraint.priority = self.priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var graph1Height: NSLayoutConstraint!
    @IBOutlet weak var graph2Height: NSLayoutConstraint!
    @IBOutlet weak var graph3Height: NSLayoutConstraint!
    @IBOutlet weak var graph4Height: NSLayoutConstraint!
    @IBOutlet weak var graph5Height: NSLayoutConstraint!
    @IBOutlet weak var graph6Height: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func change1(_ sender: Any) {
        graph1Height = graph1Height.changeMultiplier(changeMultiplier: 0.5)
        graph2Height = graph2Height.changeMultiplier(changeMultiplier: 0.9)
        graph3Height = graph3Height.changeMultiplier(changeMultiplier: 1)
        graph4Height = graph4Height.changeMultiplier(changeMultiplier: 0.3)
        graph5Height = graph5Height.changeMultiplier(changeMultiplier: 0.7)
        graph6Height = graph6Height.changeMultiplier(changeMultiplier: 0.4)
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func change2(_ sender: Any) {
        graph1Height = graph1Height.changeMultiplier(changeMultiplier: 0.7)
        graph2Height = graph2Height.changeMultiplier(changeMultiplier: 0.4)
        graph3Height = graph3Height.changeMultiplier(changeMultiplier: 0.7)
        graph4Height = graph4Height.changeMultiplier(changeMultiplier: 1)
        graph5Height = graph5Height.changeMultiplier(changeMultiplier: 0.5)
        graph6Height = graph6Height.changeMultiplier(changeMultiplier: 0.2)
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
}

