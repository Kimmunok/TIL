//
//  SelectFriendViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 15..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BEMCheckBoxDelegate {
    
    var array: [UserModel] = []
    var users = Dictionary<String,Bool>()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // DB 친구목록 불러오기
        Database.database().reference().child("users").observe(DataEventType.value, with: { (snapshot) in
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children {
                
                let fchild = child as! DataSnapshot
                let usermodel = UserModel()
                
                if let dictionary = fchild.value as? [String : Any] {
                    usermodel.setValuesForKeys(dictionary)
                    
                    if usermodel.uid == myUid { // 내 정보는 목록에 보이지 않게 건너뛴다
                        continue
                    }
                    
                    self.array.append(usermodel)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        button.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as? SelectFriendCell {
            
            view.nameLabel.text = array[indexPath.row].username
            view.profileImageView.kf.setImage(with: URL(string: array[indexPath.row].profileImageUrl!))
            view.checkbox.delegate = self
            view.checkbox.tag = indexPath.row
            
            return view
        }
        return UITableViewCell()
    }
    
    func didTap(_ checkBox: BEMCheckBox) {

        if checkBox.on {
            // 체크박스가 체크 됐을때 발생하는 이벤트
            users[self.array[checkBox.tag].uid!] = true
        } else {
            // 체크박스가 체크가 해제 됐을때 발생하는 이벤트
            users.removeValue(forKey: self.array[checkBox.tag].uid!)
        }
    }
    
    @objc func createRoom() {
        
        let myUid = Auth.auth().currentUser?.uid
        users[myUid!] = true
        let nsDic = users as NSDictionary

        
        Database.database().reference().child("chatrooms").childByAutoId().child("users").setValue(nsDic)
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

class SelectFriendCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var checkbox: BEMCheckBox!
    
}
























