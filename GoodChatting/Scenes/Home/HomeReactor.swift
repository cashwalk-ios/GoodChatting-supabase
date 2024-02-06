//
//  HomeReactor.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import ReactorKit
import UIKit
import Supabase

final class HomeReactor: Reactor {
    
    enum Action {
        case chattingAddAction(ChattingAddPopup.ChattingAddPopupAction)
        case settingAction(HomeViewController.SettingAction)
        case chattingListManagerAction(ChattingListManager.ChattingListManagerAction)
        
        case chattingAlarmStatusChange(alarm: Bool, roomId: Int)
        case chattingDelete(roomId: Int)
        case closePopupView(ChatPopupType)
    }
    
    enum Mutation {
        case setChattingList([ChattingList])
        case setChattingAlarmStatus(alarm: Bool, roomId: Int)
        case deleteChattingRoom(roomId: Int)
        case presentCreateRoomPopup(Bool)
        case presentJoinRoomPopup(Bool)
    }
    
    struct State {
        var chattingList: [ChattingList] = []
        var isPresentCreateRoomPopup: Bool = false
        var isPresentJoinRoomPopup: Bool = false
    }
    
    var initialState: State = State()
    
    init() {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .chattingAddAction(let action):
            switch action {
            case .makeRoom:
                Log.cyo("makeRoom")
                Task {
                    do {
                        try await ChattingListManager.shared.testA()
                    } catch {
                        Log.cyo("testA error \(error)")
                    }
                }
                
                return .just(Mutation.presentCreateRoomPopup(true))
            case .joinRoom:
                Log.cyo("joinRoom")
                return .just(Mutation.presentJoinRoomPopup(true))
            }
            
        case .settingAction(let action):
            switch action {
            case .edit:
                Log.cyo("seeting Edit")
                return .empty()
            case .sort:
                Log.cyo("seeting Sort")
                return .empty()
            case .all_read:
                Log.cyo("seeting All Read")
                return .empty()
            }
            
        case .chattingListManagerAction(let action):
            switch action {
            case .getList(let list):
                return .just(.setChattingList(list))
            }
            
        case .chattingAlarmStatusChange(let alarm, let roomId):
            //TODO: 채팅 알림 상태 바꾸기
            return .just(.setChattingAlarmStatus(alarm: alarm, roomId: roomId))
            
        case .chattingDelete(let roomId):
            //TODO: 채팅 방 삭제
            return .just(.deleteChattingRoom(roomId: roomId))
            
        case .closePopupView(let popupType):
            switch popupType {
            case .create:
                return .just(Mutation.presentCreateRoomPopup(false))
            case .join:
                return .just(Mutation.presentJoinRoomPopup(false))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setChattingList(let list):
            Log.cyo("setChattingList")
            newState.chattingList = list
            
        case .setChattingAlarmStatus(let alarm, let roomId):
            if let row = newState.chattingList.firstIndex(where: { $0.id == roomId }) {
                newState.chattingList[row].alarm = alarm
            }
            
        case .deleteChattingRoom(let roomId):
            newState.chattingList.removeAll(where: { $0.id == roomId })
            
        case .presentCreateRoomPopup(let isPresent):
            newState.isPresentCreateRoomPopup = isPresent
            
        case .presentJoinRoomPopup(let isPresent):
            newState.isPresentJoinRoomPopup = isPresent
        }
        
        return newState
    }
    
    func getChattingListTemp() -> [ChattingList] {
        Log.cyo("getChattingListTemp()")
        let jsonFileName = "ChattingListTempData"
        let extensionType = "json"
        
        guard let fileLocation = Bundle.main.url(forResource: jsonFileName, withExtension: extensionType) else { return [] }
        do {
            let jsonData = try Data(contentsOf: fileLocation)
            
            let decoder = JSONDecoder()
            let chattingListData = try decoder.decode([ChattingList].self, from: jsonData)
            Log.cyo("getChattingListTemp success")
            return chattingListData
        } catch {
            Log.cyo("getChattingListTemp error = \(error.localizedDescription)")
            return []
        }
    }
}

enum ChatPopupType {
    case create
    case join
}
