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
    let user_id: String
    let message: String
    let read_users: [Int]?
    let created_at: String
    
    var convertTimestamp: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
        dateformatter.timeZone = TimeZone(secondsFromGMT: 9)
        guard let dateTransString = dateformatter.date(from: created_at) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "a H:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: dateTransString)
    }
}
