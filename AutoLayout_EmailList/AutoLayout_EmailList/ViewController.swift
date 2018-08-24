//
//  ViewController.swift
//  AutoLayout_EmailList
//
//  Created by 김문옥 on 2018. 3. 12..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {
    @IBOutlet weak var contentsTitle: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var emailData: NSMutableArray = ["title", "long title", "long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long text"]
    
    @IBOutlet weak var emailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 20
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath) as! MyCell
        
        cell.contentsTitle.text = emailData[indexPath.row % emailData.count] as? String
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

