//
//  Notification+Extension.swift
//  GoodChatting
//
//  Created by Rocky on 2/22/24.
//

import Foundation

extension Notification.Name {
    
    // 초대코드 바텀시트
    static let didDismissParticipationCodeVC = Notification.Name("didDismissParticipationCodeVC")
    static let participationCodetoSideMenuVC = Notification.Name("participationCodetoSideMenuVC")
    
    // 채팅방 사이드 메뉴
    static let getOutRoom = Notification.Name("getOutRoom")
}
