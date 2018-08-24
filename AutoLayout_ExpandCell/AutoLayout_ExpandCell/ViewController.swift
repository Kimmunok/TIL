//
//  ViewController.swift
//  AutoLayout_ExpandCell
//
//  Created by 김문옥 on 2018. 3. 12..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {
    @IBOutlet weak var myLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var heightArray: NSMutableArray = []
    
    var textDataArray: NSArray = ["shot Text",
                                  "long long long long long long text",
                                  "very long long long long long long long long long long long long long long long long long long long long long long long long long long long long long text",
                                  "very very long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long text"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        for _ in 0...14 {
            heightArray.add(false)
        }
    }
    
    // 높이값 자동 계산 지정(?)
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expandCell", for: indexPath) as! MyCell
        
        cell.myLabel.text = textDataArray[indexPath.row % textDataArray.count] as? String
        
        if heightArray[indexPath.row] as! Bool == false {
            cell.myLabel.numberOfLines = 1
        } else {
            cell.myLabel.numberOfLines = 0
        }
        
        return cell
    }
    
    // 셀을 클릭했을때 호출됨
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if heightArray[indexPath.row] as! Bool == false {
            heightArray.replaceObject(at: indexPath.row, with: true)
        } else {
            heightArray.replaceObject(at: indexPath.row, with: false)
        }
        
        // tableView.reloadData() // 테이블뷰 전체화면 갱신
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }

}

