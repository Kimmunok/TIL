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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        
        checkChatRoom()
        
        self.tabBarController?.tabBar.isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
    }

    @objc func keyboardWillShow(notification: Notification) {
    
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.bottomConstraint.constant = keyboardSize.height + 20
        }
        
        UIView.animate(withDuration: 0, animations: {
            
            self.view.layoutIfNeeded()
        }, completion: { (complete) in
            
            if self.comments.count > 0 {
                
                // 채팅방화면을 맨 아래 말풍선으로 내리기
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 내 uid 일 경우 내 말풍선 셀을, 아닐경우 상대 말풍선 셀을 리턴한다
        if (self.comments[indexPath.row].uid == uid) {
            
            if let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MyMessageCell {
                
                view.messageLabel.text = self.comments[indexPath.row].message
                view.messageLabel.numberOfLines = 0
                
                if let time = self.comments[indexPath.row].timestamp {
                    
                    view.timeStampLabel.text = time.toDayTime
                }
                
                return view
                
            }
        } else {
            
            if let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as? DestinationMessageCell {
                
                view.nameLabel.text = userModel?.username
                view.messageLabel.text = self.comments[indexPath.row].message
                view.messageLabel.numberOfLines = 0
                
                if let url = URL(string: (self.userModel?.profileImageUrl)!) {
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
                        
                        guard err == nil else {
                            print(err.debugDescription)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            
                            view.profileImageView.image = UIImage(data: data!)
                            view.profileImageView.layer.cornerRadius = view.profileImageView.frame.width / 2
                            view.profileImageView.clipsToBounds = true
                            
                        }
                    }).resume()
                }
                
                if let time = self.comments[indexPath.row].timestamp {
                    
                    view.timeStampLabel.text = time.toDayTime
                }
                return view
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
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
                "message" : messageTextField.text!,
                "timestamp" : ServerValue.timestamp()
            ]
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { (err, ref) in
                
                self.messageTextField.text = ""
            }
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
                            
                            self.getDestinationInfo()
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
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                    if self.comments.count > 0 {
                        
                        // 채팅방화면을 맨 아래 말풍선으로 내리기
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
                    }
                }
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

extension Int{
    
    var toDayTime: String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM.dd HH:mm"
        
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        
        return dateFormatter.string(from: date)
    }
}

class MyMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
}

class DestinationMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
}






























