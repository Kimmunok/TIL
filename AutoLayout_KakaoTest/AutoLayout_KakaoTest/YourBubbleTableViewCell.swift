//
//  YourBubbleTableViewCell.swift
//  AutoLayout_KakaoTest
//
//  Created by 김문옥 on 2018. 3. 13..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class YourBubbleTableViewCell: UITableViewCell {

    @IBOutlet weak var bubbleText: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = 30 / 2
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
