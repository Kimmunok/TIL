//
//  ChatViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 8..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var uid: String?
    var chatRoomUid: String?
    
    var comments: [ChatModel.Comment] = []
    var userModel: UserModel?
    
    public var destinationUid: String? // 나중에 내가 채팅할 대상의 uid
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 내 uid 일 경우 내 말풍선 셀을, 아닐경우 상대 말풍선 셀을 리턴한다
        if (self.comments[indexPath.row].uid == uid) {
            
            if let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MyMessageCell {
                
                view.messageLabel.text = self.comments[indexPath.row].message
                view.messageLabel.numberOfLines = 0
                return view
                
            }
        } else {
            
            if let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as? DestinationMessageCell {
                
                view.nameLabel.text = userModel?.username
                view.messageLabel.text = self.comments[indexPath.row].message
                view.messageLabel.numberOfLines = 0
                
                if let url = URL(string: (self.userModel?.profileImageUrl)!) {
                    
                    URLSession.shared.dataTask(with: url) { (data, response, err) in
                        
                        DispatchQueue.main.async {
                            
                            view.profileImageView.image = UIImage(data: data!)
                            view.profileImageView.layer.cornerRadius = view.profileImageView.frame.width / 2
                            view.profileImageView.clipsToBounds = true
                            
                        }
                    }
                }
                return view
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        
        checkChatRoom()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func createRoom() {
        
        let createRoomInfo: Dictionary<String,Any> = [ "users" : [
            uid! : true,
            destinationUid! : true
            ]
        ]
        
        if chatRoomUid == nil {
            // 중복생성방지
            sendButton.isEnabled = false
            
            // 채팅방 생성
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo) { (err, ref) in
                
                if err == nil {
                    self.checkChatRoom()
                }
            }
        } else {
            
            let value: Dictionary<String,Any> = [
                "uid" : uid!,
                "message" : messageTextField.text!
            ]
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value)
        }
    }

    func checkChatRoom() {
        
        // 자신의 uid
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/" + uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            
            
            // 채팅방 아이디 받아오기
            if let allObjectsOfDatasnapshot = datasnapshot.children.allObjects as? [DataSnapshot] {
                for item in allObjectsOfDatasnapshot {
                    
                    if let chatRoomDic = item.value as? [String:AnyObject] {
//  chatRoomDic <~
//      ▿ 1 element
//          ▿ 0 : 2 elements
//              - key : "users"
//              ▿ value : 2 elements
//                  ▿ 0 : 2 elements
//                      - key : PuWQHlTn7MaEjSWX1cQYmOKE2By1
//                      - value : 1
//                  ▿ 1 : 2 elements
//                      - key : QXY89COQq8fhrDgc9HP50oKqHiB2
//                      - value : 1

                        
                        let chatModel = ChatModel(JSON: chatRoomDic)
                        
                        if chatModel?.users[self.destinationUid!] == true {
                            self.chatRoomUid = item.key
                            self.sendButton.isEnabled = true // 방 중복생성방지 해제
                            
                            self.getMessageList()
                        }
                    }
                }
            }
        }
    }
    
    func getDestinationInfo() {
        
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
            
            self.userModel = UserModel()
            if let snapshotDic = datasnapshot.value as? [String:Any] {
                self.userModel?.setValuesForKeys(snapshotDic)
                self.getMessageList()
            }
        })
    }
    
    func getMessageList() {
        
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value, with: { (datasnapshot) in
            
            self.comments.removeAll()
            
            if let allObjectsOfDatasnapshot = datasnapshot.children.allObjects as? [DataSnapshot] {
                
                for item in allObjectsOfDatasnapshot {
                    
                    if let itemValueDic = item.value as? [String:AnyObject] {
                        let comment = ChatModel.Comment(JSON: itemValueDic)
                        
                        self.comments.append(comment!)
                    }
                }
                
                self.tableView.reloadData()
            }
        })
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

class MyMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
}

class DestinationMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}






























