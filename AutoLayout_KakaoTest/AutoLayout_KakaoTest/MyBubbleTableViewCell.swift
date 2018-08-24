//
//  MyBubbleTableViewCell.swift
//  AutoLayout_KakaoTest
//
//  Created by 김문옥 on 2018. 3. 12..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class MyBubbleTableViewCell: UITableViewCell {

    @IBOutlet weak var bubbleText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
