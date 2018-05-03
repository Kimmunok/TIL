//
//  GroupChatRoomViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 16..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class GroupChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var destinationRoom: String?
    var uid: String?
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var comments: [ChatModel.Comment] = []
    var users: [String:AnyObject]?
    var peopleCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid

        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            
            self.users = datasnapshot.value as! [String:AnyObject]
        })
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        getMessageList()
        
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
    
    @objc func sendMessage() {
        
        let value: Dictionary<String,Any> = [
            "uid" : uid!,
            "message" : messageTextField.text!,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatrooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value) {(err, ref) in
            
            Database.database().reference().child("chatrooms").child(self.destinationRoom!).child("users").observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
                
                if let dic = datasnapshot.value as? [String:Any] {
                    
                    for item in dic.keys {
                        
                        if item == self.uid {
                            continue
                        }
                        
                        let user = self.users![item]
                        self.sendFCM(pushToken: user!["pushToken"] as! String)
                    }
                }
                
                self.messageTextField.text = ""
            })
        }
    }
    
    func sendFCM(pushToken: String?) {
        
        let url = "https://fcm.googleapis.com/fcm/send"
        let header: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Authorization" : "key=AIzaSyDpr53KoudTYY16x5F4qG1dj_dPCBQeECk"
        ]
        
        let userName = Auth.auth().currentUser?.displayName
        //        print("userName : \(String(describing: userName))")
        
        let notificationModel = NotificationModel()
        notificationModel.to = pushToken!
        notificationModel.notification.title = userName
        notificationModel.notification.text = messageTextField.text
        notificationModel.data.title = userName
        notificationModel.data.text = messageTextField.text
        
        
        let params = notificationModel.toJSON()
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            
            print("response.result.value : \(response.result.value)")
        }
        
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
            
            let destinationUser = users![self.comments[indexPath.row].uid!]
            if let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as? DestinationMessageCell {
                
                view.nameLabel.text = destinationUser!["username"] as! String
                view.messageLabel.text = self.comments[indexPath.row].message
                view.messageLabel.numberOfLines = 0
                
                let imageUrl = destinationUser!["profileImageUrl"] as! String
                
                if let url = URL(string: imageUrl) {
                    
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
    
    func setReadCount(label: UILabel?, position: Int?) {
        
        let readCount = self.comments[position!].readUsers.count
        
        if peopleCount == nil {
            
            Database.database().reference().child("chatrooms").child(destinationRoom!).child("users").observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
                
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
        
        databaseRef = Database.database().reference().child("chatrooms").child(self.destinationRoom!).child("comments")
        
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
                                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                            }
                        }
                    })
                } else { // 마지막 메시지를 읽었을 경우
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        
                        if self.comments.count > 0 {
                            
                            // 채팅방화면을 맨 아래 말풍선으로 내리기
                            self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                        }
                    }
                }
            }
        })
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
