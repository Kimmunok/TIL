//
//  ViewController.swift
//  AutoLayout_KakaoTest
//
//  Created by 김문옥 on 2018. 3. 12..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    var chatData: NSMutableArray! = ["hi", "oh hello"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 외부에서 들여온 셀을 가져오기 위한 선행작업
        chatTableView.register(UINib(nibName: "MyBubbleTableViewCell", bundle: nil), forCellReuseIdentifier: "myBubbleCell")
        
        chatTableView.register(UINib(nibName: "YourBubbleTableViewCell", bundle: nil), forCellReuseIdentifier: "yourBubbleCell")
        
        inputTextView.delegate = self
        
        // 높이 자동 조절
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        // 키보드의 노티피케이션
        // 시스템에서 자동으로 키보드가 나타날때/사라질때 내가 만든 함수가 호출되도록 옵저버를 등록함
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // 텍스트뷰에 글자를 쓸 때 마다 호출됨
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.contentSize.height <= 83 {
            // 텍스트뷰의 높이가 콘텐트사이즈의 높이와 똑같아진다
            textViewHeight.constant = textView.contentSize.height
            
            // 텍스트뷰와 콘텐트사이즈의 높이가 미세하게 맞지않는 것을 조정
            textView.setContentOffset(CGPoint.zero, animated: false)
        }
        self.view.layoutIfNeeded() // !!!
    }
    
    @IBAction func textInputDone(_ sender: Any) {
        
        if inputTextView.hasText {
            chatData.add(inputTextView.text)
            chatTableView.reloadData()
            
            inputTextView.text = ""
            
            let lastIndexPath = NSIndexPath(row: chatData.count - 1, section: 0) as IndexPath
            self.view.layoutIfNeeded() // !!!
            
            chatTableView.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: false)
            
            self.textViewDidChange(inputTextView)
        }
    }
    
    @objc func keyboardWillShow(noti: NSNotification) {
        
        // 키보드의 높이를 가져오는 작업
        let notiInfo = noti.userInfo! as NSDictionary
        let keyboardFrame = notiInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect // 키보드가 나타날때의 프레임을 시스템상에서 가져올수 있다
        let height = keyboardFrame.size.height
        
        // 키보드 높이만큼 간격을 띄어 준다
        inputViewBottomMargin.constant = -height
        
        // 애니메이션 추가
        // 키보드의 움직이는 시간을 가져와야 함
        // 그 시간만큼 텍스트인풋뷰를 애니메이션 형태로 올라오게 만들면 자연스럽게 보인다
        let animationDuration = notiInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded() // !!!
        }
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        
        inputViewBottomMargin.constant = 0
        
        let notiInfo = noti.userInfo! as NSDictionary
        
        let animationDuration = notiInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded() // !!!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    // 높이 자동 조절
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let defaultCell: UITableViewCell
        
        // 홀수판별
        if indexPath.row % 2 == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myBubbleCell", for: indexPath) as! MyBubbleTableViewCell
            cell.bubbleText.text = (chatData[indexPath.row] as! String)
//            print(chatData[indexPath.row]) // TEST
            
            defaultCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "yourBubbleCell", for: indexPath) as! YourBubbleTableViewCell
            cell.bubbleText.text = (chatData[indexPath.row] as! String)
//            print(chatData[indexPath.row]) // TEST
            
            defaultCell = cell
        }
        defaultCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return defaultCell
    }

}

