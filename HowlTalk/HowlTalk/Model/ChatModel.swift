//
//  ChatModel.swift
//  HowlTalk
//
//  Created by 김문옥 on 2018. 4. 8..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {

    public var users: Dictionary<String,Bool> = [:] // 채팅방에 참여한 사람들
    public var comments: Dictionary<String,Comment> = [:] // 채팅방의 대화내용
    
// users <~
//
//  ▿ some : 2 elements
//      ▿ 0 : 2 elements
//          - key : "PuWQHlTn7MaEjSWX1cQYmOKE2By1"
//          - value : true
//      ▿ 1 : 2 elements
//          - key : "QXY89COQq8fhrDgc9HP50oKqHiB2"
//          - value : true
//
// comments <~
//    
//  ▿ some : 3 elements
//      ▿ 0 : 2 elements
//          - key : "-L9ZJNoMc4zKzUMKlh8-" // my uid
//          ▿ value : <Comment: 0x60000029bcb0> // hi1
//      ▿ 1 : 2 elements
//          - key : "-L9ZJQ7Co7gSx00_HchC" // my uid
//          ▿ value : <Comment: 0x60000028b450> // hi2
//      ▿ 2 : 2 elements
//          - key : "-L9ZJQrOSdVTIDf26h8w" // my uid
//          ▿ value : <Comment: 0x60000028b5e0> // hi3




    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment: Mappable {
        
        public var uid: String?
        public var message: String?
        public var timestamp: Int?
        public var readUsers: Dictionary<String,Bool> = [:]
        
        public required init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timestamp <- map["timestamp"]
            readUsers <- map["readUsers"]
        }
    }
}
