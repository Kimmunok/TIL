//
//  HomeController.swift
//  HowlFireBaseLogin
//
//  Created by 김문옥 on 2018. 3. 29..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var array: [UserDTO] = []
    var uidKey: [String] = []
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var collectView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return array.count
    }
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RowCell", for: indexPath) as! CustomCell
        
        cell.subject.text = array[indexPath.row].subject
        cell.explaination.text = array[indexPath.row].explaination
        
        // 스레드를 사용해야 콜렉션뷰셀의 바인딩을 렉없이 할 수 있다
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].imageUrl!)!) { (data, response, err) in
            if err != nil {
                print(err as Any)
                return
            }
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data!)
            }
        }.resume()

        
        cell.starButton.tag = indexPath.row
        cell.starButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
        
        // 좋아요가 클릭되어있을 경우
        if let _ = self.array[indexPath.row].stars?[(Auth.auth().currentUser?.uid)!] {
            cell.starButton.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal)
        } else {
            cell.starButton.setImage(#imageLiteral(resourceName: "ic_favorite_border"), for: .normal)
        }
        
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(delete(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        Database.database().reference().child("users").observe(DataEventType.value, with: {(DataSnapshot) in
        //
        //            self.array.removeAll()
        //
        //            for child in DataSnapshot.children {
        //                print("child : \(child)")
        //                let fchild = child as! DataSnapshot
        //                let userDTO = UserDTO()
        //                print("fchild.value : \(fchild.value)")
        //                UserDTO.setValuesForKeys(fchild.value as! [String:Any])
        //                self.array.append(userDTO)
        //            }
        //            self.collectView.reloadData()
        //        })
        
        
        refreshControl = UIRefreshControl()
        
        // Customizing the Refresh Control
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "데이터베이스 갱신중 ...", attributes: nil)
        
        // Refresh Control 구성
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectView.refreshControl = refreshControl
        } else {
            collectView.addSubview(refreshControl)
        }
        
        self.activityIndicatorView.startAnimating()
        
        // DB 목록 불러오기
        self.observeDB()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleRefresh() {
        
        observeDB()
        
        self.refreshControl.endRefreshing()
    }
    
    func observeDB() {
        
        Database.database().reference().child("users").observe(DataEventType.value, with: {(DataSnapshot) in
            self.array.removeAll()
            self.uidKey.removeAll()
            
            for child in DataSnapshot.children {
                let fchild = child as! DataSnapshot
                
                if let dictionary = fchild.value as? [String:Any] {
                    let user = UserDTO()
                    let uidKey = fchild.key
                    
                    user.setValuesForKeys(dictionary)
                    self.array.append(user)
                    self.uidKey.append(uidKey)
                }
            }
            
            DispatchQueue.main.async {
                self.collectView.reloadData()
                self.activityIndicatorView.stopAnimating()
            }
        })
    }
    
    @objc func like(_ sender: UIButton) {
        
        Database.database().reference().child("users").child(self.uidKey[sender.tag]).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var stars: Dictionary<String, Bool>
                stars = post["stars"] as? [String : Bool] ?? [:]
                var starCount = post["starCount"] as? Int ?? 0
                if let _ = stars[uid] {
                    // Unstar the post and remove self from stars
                    starCount -= 1
                    stars.removeValue(forKey: uid)
                } else {
                    // Star the post and add self to stars
                    starCount += 1
                    stars[uid] = true
                }
                post["starCount"] = starCount as AnyObject?
                post["stars"] = stars as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func delete(sender: UIButton) {
        
        Storage.storage().reference().child("ios_images").child(self.array[sender.tag].imageName!).delete { (err) in
            if err != nil {
                print("DELETE ERROR : \(err!)")
            } else {
                Database.database().reference().child("users").child(self.uidKey[sender.tag]).removeValue()
            }
        }
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

class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var explaination: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
}
