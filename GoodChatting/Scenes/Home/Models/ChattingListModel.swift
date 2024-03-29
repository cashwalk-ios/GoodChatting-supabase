//
//  ChattingListModel.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/16/24.
//

import Foundation

struct ChattingRoomItem: Codable {
    var title: String
    var image: String?
    var maker: String
    var people: [String]
    var updated_at: Date
    var active_participation_code: String
}

struct ChattingList: Codable {
    var id: Int
    var created_at: Date
    
    var title: String?
    var image: String?
    var maker: String?
    var people: [String]?
    var messages: [String]?
    var updated_at: Date?
    var alarm: Bool?
    
    var newmessageCYO: [MessageCYO]?
    var roomUserCYO: [RoomUserCYO]?
    
    var active_participation_code: String?
}

struct MessageCYO: Codable {
    var id: String
    var created_at: Date
    
    var user_id: String?
    var message: String?
}

struct RoomUserCYO: Codable {
    var id: Int
    
    var user_id: String?
    var nickname: String?
}

struct UserCYO: Codable {
    let id: String
    var created_at: Date?
    var room_ids: [Int]?
    let email: String?
}

struct AddRoomUserCYOModel: Codable {
    let room_id: Int
    let user_id: String
    let nickname: String
}
