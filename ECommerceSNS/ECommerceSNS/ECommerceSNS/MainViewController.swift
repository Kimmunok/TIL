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
    
    @IBOutlet var leadingC: NSLayoutConstraint!
    @IBOutlet var trailingC: NSLayoutConstraint!
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var inputTextView: UIView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var writeTimelineBtn: UIButton!
    @IBOutlet var timelineTextField: UITextField!
    
    var hamburgerMenuIsVisible = false
  
    var infoTableArray = [String]()
    var profileImageArray = [String]()
    var userNameArray = [String]()
    var timeStampArray = [String]()
    var timelineTextArray = [String]()
    
    @IBOutlet var infoTableView: UITableView!
    
    var uid: String?
    var timelineUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Cloud Firestore 인스턴스를 초기화합니다.
        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        
        infoTableView.dataSource = self
        infoTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        guard Auth.auth().currentUser?.uid != nil else {
            print("User ID is missing!")
            return
        }
        
        uid = Auth.auth().currentUser?.uid
        
        writeTimelineBtn.addTarget(self, action: #selector(writeTimeline), for: .touchUpInside)
        
        // 실시간 업데이트 가져오기 (MyInfo)
        db.collection("users").document(uid!).addSnapshotListener { DocumentSnapshot, error in

            guard let document = DocumentSnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }

            let googleEmail = document.data().map { $0["googleEmail"]! } as! String
            let googleName = document.data().map { $0["googleName"]! } as! String
            let userEmail = document.data().map { $0["userEmail"]! } as! String
            let userName = document.data().map { $0["userName"]! } as! String

            self.infoTableArray = [googleEmail, googleName, userEmail, userName]
            print("infoTableArray : \(self.infoTableArray)")

            DispatchQueue.main.async {
                self.infoTableView.reloadData()
            }
        }
        
        // 컬렉션의 여러 문서 수신 대기 (timelines)
        db.collection("timelines").order(by: "timeStamp", descending: true).addSnapshotListener { querySnapshot, error in

            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            for document in documents {
                
                self.userNameArray.append(document.data()["userName"]! as! String)
                
                let timeStamp = document.data()["timeStamp"]! as! NSNumber
                
                self.timeStampArray.append(timeStamp.toDayTime)
                
                self.timelineTextArray.append(document.data()["timelineText"]! as! String)
            }

            
//            let date = Date(timeIntervalSince1970: timeStamps[0] as! TimeInterval)
            
            
            
            
//            self.userNameArray = userNames as! [String]
//            self.timeStampArray = date as! [String]
//            self.timelineTextArray = timelineTexts as! [String]
            
            print("Main Table's Array : \(self.userNameArray), \(self.timelineTextArray)")

            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // 셀간 구분선 없애기
        infoTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // 높이 자동 조절
//        mainTableView.estimatedRowHeight = 100;
//        mainTableView.rowHeight = UITableViewAutomaticDimension
        mainTableView.rowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
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
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.bottomConstraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        self.bottomConstraint.constant = 0
        self.view.layoutIfNeeded()

    }
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    @objc func writeTimeline() {
        
        // 메시지 내용이 비었으면 무시한다.
        guard self.timelineTextField.text != "" else {
            return
        }
        
        profileImageArray.removeAll()
        userNameArray.removeAll()
        timeStampArray.removeAll()
        timelineTextArray.removeAll()
        
        // Cloud Firestore 인스턴스를 초기화합니다.
        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        
        // 유저네임 불러오기
        db.collection("users").document(uid!).getDocument { (document, error) in

            if let document = document, document.exists {
                
                let userName = document.data().map { $0["userName"]! } as! String
                
                let value: Dictionary<String,Any> = [
                    "uid" : self.uid!,
                    "userName" : userName,
                    "timeStamp" : Date().timeIntervalSince1970,
                    "timelineText" : self.timelineTextField.text!
                ]
                
                var ref: DocumentReference? = nil
                
                // 타임라인 저장하기
                ref = db.collection("timelines").addDocument(data: value) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
            
            self.timelineTextField.text = ""
        }
        
        DispatchQueue.main.async {
            
            
            self.mainTableView.reloadData()
            
            let indexPath = NSIndexPath(item: NSNotFound, section: 0) as IndexPath
            self.mainTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        if tableView == infoTableView {
            
            return infoTableArray.count
        }
        
        if tableView == mainTableView {
            
            return userNameArray.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        if tableView == infoTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as UITableViewCell
            
            cell.textLabel?.text = infoTableArray[indexPath.row]
            
            return cell
        }
        
        if tableView == mainTableView {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? TimelineCell else {
                
                print("no have timelineCell!!!")
                return UITableViewCell()
            }
            
            cell.profileImageView.layer.masksToBounds = false
            cell.profileImageView.layer.cornerRadius = 10
            cell.clipsToBounds = true
            
            cell.userNameLabel?.text = userNameArray[indexPath.row]
            cell.timeStampLabel?.text = timeStampArray[indexPath.row]
            cell.timelineLabel?.text = timelineTextArray[indexPath.row]
            
            return cell
        }

        return UITableViewCell()
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

class TimelineCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var timeStampLabel: UILabel!
    @IBOutlet var timelineLabel: UILabel!
    
}

extension NSNumber {

    var toDayTime: String {

        let dateFormatter = DateFormatter()

        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM.dd HH:mm"

        let date = Date(timeIntervalSince1970: TimeInterval(truncating: self))

        return dateFormatter.string(from: date)
    }
}





