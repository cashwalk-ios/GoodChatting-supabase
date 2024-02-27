//
//  ChatModel.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 2/8/24.
//

import Foundation

struct ChatMessageModel: Codable, Equatable {
    let id: String
    let room_id: Int
    let user_id: String
    let message: String
    let read_users: [Int]?
    let created_at: String
    
    private var convertDate: Date {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
        dateformatter.timeZone = TimeZone(secondsFromGMT: 9)
        guard let dateTransString = dateformatter.date(from: created_at) else {
            return Date()
        }
        
        return dateTransString
    }
    
    private func convertDate(dateString: String) -> Date {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
        dateformatter.timeZone = TimeZone(secondsFromGMT: 9)
        guard let stringToDate = dateformatter.date(from: dateString) else {
            return Date()
        }
        
        return stringToDate
    }
    
    /// 채팅 시간 노출 프로퍼티
    var convertTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a H:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: convertDate)
    }
    
    /// 이전 셀과 현재 셀 날짜 비교
    func isCompareCreateDate(previousCellDate: String, currentCellDate: String) -> Bool {
        
        let previousDate = convertDate(dateString: previousCellDate)
        let currenctDate = convertDate(dateString: currentCellDate)
        
        Log.cyo("Compare1: \(previousDate)")
        Log.cyo("Compare2: \(currenctDate)")
        
        switch previousDate.compare(currenctDate) {
        case .orderedAscending: return false
        default: return true
        }
    }
    
    /// 날짜 셀 노출 프로퍼티
    var displayDateCell: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy년 MM월 dd일"
        return dateformatter.string(from: convertDate)
    }
    
    /// 채팅 시간 비교
    func isCompareChatDate(previousCellDate: String, currentCellDate: String) -> Bool {
        
        let previousDate = convertDate(dateString: previousCellDate)
        let currentDate = convertDate(dateString: currentCellDate)

        let priviousHour = Calendar.current.component(.hour, from: previousDate)
        let currentHour = Calendar.current.component(.hour, from: currentDate)
        
        let priviousMinute = Calendar.current.component(.minute, from: previousDate)
        let currentMinute = Calendar.current.component(.minute, from: currentDate)
        
        return priviousHour == currentHour && priviousMinute == currentMinute
    }
}
