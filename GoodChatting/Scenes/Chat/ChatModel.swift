//
//  ChatModel.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 2/8/24.
//

import Foundation

struct ChatMessageModel: Codable {
    let id: Int
    let room_id: Int
    let user_id: Int
    let message: String
    let read_users: [Int]?
}
