//
//  MainViewController.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 6..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import MaterialComponents

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var array: [UserModel] = []
    var tableview: UITableView!
    
    @IBOutlet weak var logoutButton: MDCFlatButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a Flat Button
        
        //        logoutButton.setTitle("Tap me", for: .normal)
        logoutButton.sizeToFit()
        logoutButton.addTarget(self, action: #selector(logoutEvent), for: .touchUpInside)
        self.view.addSubview(logoutButton)
        
        tableview = UITableView()
        tableview.delegate = self
        tableview.dataSource = self
        
        // 테이블뷰셀 생성
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableview)
        
        // 테이블뷰 레이아웃
        tableview.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(60)
            m.bottom.left.right.equalTo(view)
        }
        
        // DB 접속
        Database.database().reference().child("users").observe(DataEventType.value, with: { (snapshot) in
            
            for child in snapshot.children {
                
                let fchild = child as! DataSnapshot
                let usermodel = UserModel()
                
                if let dictionary = fchild.value as? [String : Any] {
                    usermodel.setValuesForKeys(dictionary)
                    self.array.append(usermodel)
                }
            }
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        })

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let imageview = UIImageView()
        
        cell.addSubview(imageview)
        imageview.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(20)
            m.height.width.equalTo(50)
        }
        
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { (data, response, err) in
            
            DispatchQueue.main.async {
                imageview.image = UIImage(data: data!)
                imageview.layer.cornerRadius = imageview.frame.size.width / 2
                imageview.clipsToBounds = true
            }
        }.resume()
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageview.snp.right).offset(30)
        }
        
        label.text = array[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
 

    
    @objc func logoutEvent() {
        
        try! Auth.auth().signOut()
        
        if let view = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? UIViewController {
            self.present(view, animated: true, completion: nil)
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



















