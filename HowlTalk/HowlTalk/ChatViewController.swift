//
//  ChatViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 8..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import Kingfisher

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var uid: String?
    var chatRoomUid: String?
    
    var comments: [ChatModel.Comment] = []
    var destinationUserModel: UserModel?
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var peopleCount: Int?
    
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
        
        // 셀간 구분선 없애기
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
        
        databaseRef?.removeObserver(withHandle: observe!)
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
                
                setReadCount(label: view.readCounterLabel, position: indexPath.row)
                
                return view
                
            }
        } else {
            
            if let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as? DestinationMessageCell {
                
                view.nameLabel.text = destinationUserModel?.username
                view.messageLabel.text = self.comments[indexPath.row].message
                view.messageLabel.numberOfLines = 0
                
                if let url = URL(string: (self.destinationUserModel?.profileImageUrl)!) {
                    
                    view.profileImageView.layer.cornerRadius = view.profileImageView.frame.width / 2
                    view.profileImageView.clipsToBounds = true
                    view.profileImageView.kf.setImage(with: url)
                }
                
                if let time = self.comments[indexPath.row].timestamp {
                    
                    view.timeStampLabel.text = time.toDayTime
                }
                
                setReadCount(label: view.readCounterLabel, position: indexPath.row)
                
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
        
        // 메시지 내용이 비었으면 무시한다.
        guard self.messageTextField.text != "" else {
            return
        }
        
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

                self.sendFCM()
                self.messageTextField.text = ""
            }
        }
    }
    
    func sendFCM() {
        
        let url = "https://fcm.googleapis.com/fcm/send"
        let header: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Authorization" : "key=AIzaSyDpr53KoudTYY16x5F4qG1dj_dPCBQeECk"
        ]
        
        let userName = Auth.auth().currentUser?.displayName
        //        print("userName : \(String(describing: userName))")
        
        let notificationModel = NotificationModel()
        notificationModel.to = destinationUserModel?.pushToken
        notificationModel.notification.title = userName
        notificationModel.notification.text = messageTextField.text
        notificationModel.data.title = userName
        notificationModel.data.text = messageTextField.text
        
        
        let params = notificationModel.toJSON()
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            
            print("response.result.value : \(response.result.value)")
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
                        
                        if (chatModel?.users[self.destinationUid!] == true && chatModel?.users.count == 2) {
                            
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
            
            self.destinationUserModel = UserModel()
            if let snapshotDic = datasnapshot.value as? [String:Any] {
                self.destinationUserModel?.setValuesForKeys(snapshotDic)
                self.getMessageList()
            }
        })
    }
    
    func setReadCount(label: UILabel?, position: Int?) {
        
        let readCount = self.comments[position!].readUsers.count
        
        if peopleCount == nil {
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("users").observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
                
                if let dic = datasnapshot.value as? [String:Any] {
                    
                    self.peopleCount = dic.count
                    
                    let noReadCount = self.peopleCount! - readCount
                    
                    if noReadCount > 0 {
                        
                        label?.isHidden = false
                        label?.text = String(noReadCount)
                    } else {
                        label?.isHidden = true
                    }
                }
            })
        } else {
            
            let noReadCount = peopleCount! - readCount
            
            if noReadCount > 0 {
                
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }
    }
    
    func getMessageList() {
        
        databaseRef = Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments")
        
        observe = databaseRef?.observe(DataEventType.value, with: { (datasnapshot) in
            
            self.comments.removeAll()
            
            var readUserDic: Dictionary<String,AnyObject> = [:]
            
            if let allObjectsOfDatasnapshot = datasnapshot.children.allObjects as? [DataSnapshot] {
                
                for item in allObjectsOfDatasnapshot {
                    
                    let key = item.key as String
                    
                    if let itemValueDic = item.value as? [String:AnyObject] {
                        let comment = ChatModel.Comment(JSON: itemValueDic)
                        let comment_motify = ChatModel.Comment(JSON: itemValueDic)

                        // 메시지를 읽었음을 표시
                        comment_motify?.readUsers[self.uid!] = true
                        readUserDic[key] = comment_motify?.toJSON() as! NSDictionary
                        
                        self.comments.append(comment!)
                    }
                }
                
                let nsDic = readUserDic as NSDictionary
                
                if self.comments.last?.readUsers.keys == nil {
                    return
                }
                
                // 마지막 메시지를 읽지 않았을 경우, 서버에게 메시지 읽음을 보고하는 부분
                if (!(self.comments.last?.readUsers.keys.contains(self.uid!))!) {
                
                datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in

                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        
                        if self.comments.count > 0 {
                            
                            // 채팅방화면을 맨 아래 말풍선으로 내리기
                            self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
                        }
                    }
                })
                } else { // 마지막 메시지를 읽었을 경우
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        
                        if self.comments.count > 0 {
                            
                            // 채팅방화면을 맨 아래 말풍선으로 내리기
                            self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
                        }
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
    @IBOutlet weak var readCounterLabel: UILabel!
    
}

class DestinationMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var readCounterLabel: UILabel!
    
}






























