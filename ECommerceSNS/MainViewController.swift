//
//  MainViewController.swift
//  ECommerceSNS
//
//  Created by 김문옥 on 2018. 9. 6..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GIDSignInUIDelegate {
    
    @IBOutlet var coverView: UIView!
    @IBOutlet var leadingC: NSLayoutConstraint!
    @IBOutlet var trailingC: NSLayoutConstraint!
    
    var hamburgerMenuIsVisible = false
  
    @IBAction func hamburgerBtnTapped(_ sender: Any) {
        
        if !hamburgerMenuIsVisible {
            leadingC.constant = -300
//            trailingC.constant = -300
            
            hamburgerMenuIsVisible = true
        } else {
            leadingC.constant = 0
//            trailingC.constant = 0
            
            hamburgerMenuIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
    }
    
    var TableArray = [String]()
    @IBOutlet var infoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        infoTableView.dataSource = self
        infoTableView.delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Cloud Firestore 인스턴스를 초기화합니다.
        let db = Firestore.firestore()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User ID is missing!")
            return
        }
        
        // 실시간 업데이트 가져오기
        db.collection("users").document(uid).addSnapshotListener { DocumentSnapshot, error in
            guard let document = DocumentSnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            let googleEmail = document.data().map { $0["googleEmail"]! } as! String
            let googleName = document.data().map { $0["googleName"]! } as! String
            let userEmail = document.data().map { $0["userEmail"]! } as! String
            let userName = document.data().map { $0["userName"]! } as! String
            
            self.TableArray = [googleEmail, googleName, userEmail, userName]
            print("TableArray : \(self.TableArray)")
            
            DispatchQueue.main.async {
                self.infoTableView.reloadData()
            }
        }
        
        // 셀간 구분선 없애기
        infoTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TableArray[indexPath.row]
        
        
//        // 사이드메뉴의 내부요소가 넘치지 않게 label에 constraint 걸어서 우측 끝에 붙이기
//        cell.textLabel!.snp.makeConstraints { (m) in
//            m.left.equalTo(cell).offset(80)
//        }
        
        return cell
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
