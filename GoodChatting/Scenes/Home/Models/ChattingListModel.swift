//
//  ChattingListModel.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/16/24.
//

import Foundation

struct ChattingListModel: Codable {
    var list: [ChattingList]
    
    struct ChattingList: Codable {
        var image: String
        var title: String
        var number: Int
        var lastest: String
        var update_at: String
        var unRead: Int
    }
}
