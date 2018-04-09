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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 로그아웃 바버튼아이템
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "로그아웃", style: .plain, target: self, action: #selector(logoutEvent))
        
        tableview = UITableView()
        tableview.delegate = self
        tableview.dataSource = self
        
        // 테이블뷰셀 생성
        tableview.register(PeopleTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableview)
        
        // 테이블뷰 레이아웃
        tableview.snp.makeConstraints { (m) in
            m.top.equalTo(view)
            m.bottom.left.right.equalTo(view)
        }
        
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
                self.tableview.reloadData()
            }
        })

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PeopleTableViewCell {
            
            let imageview = cell.imageview!
            
            imageview.snp.makeConstraints { (m) in
                m.centerY.equalTo(cell)
                m.left.equalTo(cell).offset(10)
                m.height.width.equalTo(50)
            }
            
            URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { (data, response, err) in
                
                DispatchQueue.main.async {
                    imageview.image = UIImage(data: data!)
                    imageview.layer.cornerRadius = imageview.frame.size.width / 2
                    imageview.clipsToBounds = true
                }
                }.resume()
            
            let label = cell.label!

            label.snp.makeConstraints { (m) in
                m.centerY.equalTo(cell)
                m.left.equalTo(imageview.snp.right).offset(20)
            }
            
            label.text = array[indexPath.row].username
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.array[indexPath.row].uid
        self.navigationController?.pushViewController(view!, animated: true)
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

class PeopleTableViewCell: UITableViewCell {
    
    var imageview: UIImageView! = UIImageView()
    var label: UILabel! = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




























