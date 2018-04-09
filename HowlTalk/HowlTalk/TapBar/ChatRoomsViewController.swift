//
//  ChatRoomsViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 9..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var uid: String!
    var chatrooms: [ChatModel]! = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
    }
    
    func getChatroomsList() {
        
        // 나의 uid가 있는 chatRoomUid를 불러온다
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/" + uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
            
            if let allObjectsOfDatasnapshot = datasnapshot.children.allObjects as? [DataSnapshot] {
                
                for item in allObjectsOfDatasnapshot {
                    
                    if let chatroomDic = item.value as? [String:AnyObject] {
                        
                        let chatmodel = ChatModel(JSON: chatroomDic)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath)
        
        return cell
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
