//
//  GroupChatRoomViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 16..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase

class GroupChatRoomViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    var destinationRoom: String?
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid

        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            
            let dic = datasnapshot.value as! [String:AnyObject]
        })
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc func sendMessage() {
        
        let value: Dictionary<String,Any> = [
            "uid" : uid!,
            "message" : messageTextField.text!,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatrooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value) {(err, ref) in
            
            self.messageTextField.text = ""
        }
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
