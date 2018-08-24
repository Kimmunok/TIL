//
//  UserDTO.swift
//  HowlFireBaseLogin
//
//  Created by 김문옥 on 2018. 3. 31..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

@objcMembers
class UserDTO: NSObject {

    var uid: String?
    var userId: String?
    var subject: String?
    var explaination: String?
    var imageUrl: String?
    var starCount: NSNumber?
    var stars: [String:Bool]?
    var imageName: String?
}
