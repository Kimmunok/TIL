//
//  InfoTableViewController.swift
//  ECommerceSNS
//
//  Created by 김문옥 on 2018. 8. 29..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn
import SnapKit

class InfoTableViewController: UITableViewController, GIDSignInUIDelegate {

    var TableArray = [String]()
    @IBOutlet var infoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
//        TableArray = ["googleEmail", "googleName", "userEmail", "userName"]
        
        // Cloud Firestore 인스턴스를 초기화합니다.
        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User ID is missing!")
            return
        }
        
//        // 문서 가져오기 (데이터 읽기)
//        db.collection("users").document(uid).getDocument { (document, error) in
//            guard error == nil else {
//                print("문서 가져오기 에러!")
//                return
//            }
//            if let document = document, document.exists {
//
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
//
//                let googleEmail = document.data().map { $0["googleEmail"]! } as! String
//                let googleName = document.data().map { $0["googleName"]! } as! String
//                let userEmail = document.data().map { $0["userEmail"]! } as! String
//                let userName = document.data().map { $0["userName"]! } as! String
//
//                self.TableArray = [googleEmail, googleName, userEmail, userName]
//
//            } else {
//                print("Document does not exist")
//            }
//
//            DispatchQueue.main.async {
//                self.infoTableView.reloadData()
//            }
//        }
        
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
            
            DispatchQueue.main.async {
                self.infoTableView.reloadData()
            }

        }
        
        // 사이드메뉴의 내부요소가 넘치지 않게 뷰의 가로 폭 맞추기
        self.view.frame.size.width = self.revealViewController().rearViewRevealWidth
        self.infoTableView.reloadData()
        
        // 셀간 구분선 없애기
        infoTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TableArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TableArray[indexPath.row]
        
        
        // 사이드메뉴의 내부요소가 넘치지 않게 label에 constraint 걸어서 우측 끝에 붙이기
        cell.textLabel!.snp.makeConstraints { (m) in
            m.left.equalTo(cell).offset(80)
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//
//        guard let DestVC = segue.destination as? InfoViewController else { return }
//
//        let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
//
//        // 사이드 메뉴의 항목 하나를 누르면
////        DestVC.varView = indexPath.row
//
//    }
}












