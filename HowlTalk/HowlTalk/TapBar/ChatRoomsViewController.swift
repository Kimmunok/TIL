//
//  ChatRoomsViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 9..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var uid: String!
    var chatrooms: [ChatModel]! = []
    var keys: [String] = []
    var destinationUsers: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
        
        // 셀간 구분선 없애기
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
    }
    
    func getChatroomsList() {
        
        // 나의 uid가 있는 chatRoomUid를 불러온다
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/" + uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
            
            if let allObjectsOfDatasnapshot = datasnapshot.children.allObjects as? [DataSnapshot] {
                
                for item in allObjectsOfDatasnapshot {
                    
                    self.chatrooms.removeAll()
                    
                    if let chatroomDic = item.value as? [String:AnyObject] {
                        
                        let chatmodel = ChatModel(JSON: chatroomDic)
                        
                        self.keys.append(item.key)
                        self.chatrooms.append(chatmodel!)
                    }
                }
            }
            
            DispatchQueue.main.async {
            
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as? CustomCell {
            
            var destinationUid: String?
            
            // 내 uid는 제외하고 상대방의 uid만 가져온다
            for item in chatrooms[indexPath.row].users {
                
                if item.key != self.uid {
                    
                    destinationUid = item.key
                    destinationUsers.append(destinationUid!)
                }
            }
            
            // 가져온 대화상대의 uid를 사용하여 이름을 가져온다
            Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
                
                if let snapshotDic = datasnapshot.value as? [String:AnyObject] {
                    
                    let usermodel = UserModel()
                    
                    usermodel.setValuesForKeys(snapshotDic)
                    cell.titleLabel.text = usermodel.username
                    
                    if let url = URL(string: usermodel.profileImageUrl!) {
                        
                        cell.imageview.layer.cornerRadius = cell.imageview.frame.width / 2
                        cell.imageview.layer.masksToBounds = true
                        cell.imageview.kf.setImage(with: url)
                    }
                }
                
                if self.chatrooms[indexPath.row].comments.keys.count == 0 {
                    return
                }
                
                let lastMessageKey = self.chatrooms[indexPath.row].comments.keys.sorted(){$0>$1} // 무작위로 가져온 메시지의 키값을 오름차순으로 가져온다
                cell.lastMessageLabel.text = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.message
                
                let unixTime = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.timestamp
                cell.timeStampLabel.text = unixTime?.toDayTime
            })
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.destinationUsers[indexPath.row].count > 2 {
            
            let destinationUid = self.destinationUsers[indexPath.row]
            
            if let view = self.storyboard?.instantiateViewController(withIdentifier: "GroupChatRoomViewController") as? GroupChatRoomViewController {
                
                view.destinationRoom = self.keys[indexPath.row]
                self.navigationController?.pushViewController(view, animated: true)
            }
        } else {
        
            let destinationUid = self.destinationUsers[indexPath.row]
            
            if let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                
                view.destinationUid = destinationUid
                self.navigationController?.pushViewController(view, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
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

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
}













