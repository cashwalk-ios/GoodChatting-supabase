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
}

struct ChattingList: Codable {
    var id: Int
    var created_at: Date
    
    var title: String?
    var image: String?
    var maker: String?
    var people: [String]?
    var messages: [Int]?
    var updated_at: Date?
    var alarm: Bool?
    
    var messageCYO: [MessageCYO]?
    var roomUserCYO: [RoomUserCYO]?
}

struct MessageCYO: Codable {
    var id: Int
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
