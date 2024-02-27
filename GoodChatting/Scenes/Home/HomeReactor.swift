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
        case chattingDelete(item: ChattingList?)
        case closePopupView(ChatPopupType)
        case successJoinChattingRoom(String)
    }
    
    enum Mutation {
        case setChattingList([ChattingList])
        case setChattingAlarmStatus(alarm: Bool, roomId: Int)
        case presentCreateRoomPopup(Bool)
        case presentJoinRoomPopup(Bool, String?)
        case enterChattingRoom(String)
    }
    
    struct State {
        var chattingList: [ChattingList] = []
        var isPresentCreateRoomPopup: Bool = false
        var isPresentJoinRoomPopup: Bool = false
        var userCYO: UserCYO?
        var joinCode: String? = nil
        var chatRoomTitle: String?
    }
    
    var initialState: State// = State()
    
    init(userCYO: UserCYO?) {
        initialState = State(userCYO: userCYO)
        Log.kkr("userCYO's id: \((userCYO?.id) ?? "is nil"), userCYO's room_ids: \(userCYO?.room_ids ?? [])")
        
        if let userId = userCYO?.id {
            Task {
                do {
                    try await ChattingListManager.shared.getChattingList(userId: userId)
                    try await ChattingListManager.shared.subcribeChannelRoom(userId: userId)
                } catch {
                    Log.cyo("get Room Error \(error.localizedDescription)")
                }
            }
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .chattingAddAction(let action):
            switch action {
            case .makeRoom:
                Log.cyo("makeRoom")
                return .just(Mutation.presentCreateRoomPopup(true))
            case .joinRoom(let code):
                Log.cyo("joinRoom")
                return .just(Mutation.presentJoinRoomPopup(true, code))
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
            
        case .chattingDelete(let item):
            //TODO: 채팅 방 삭제
            if let item {
                ChattingListManager.shared.getoutRoom(userId: currentState.userCYO?.id ?? "", roomData: item)
            }
            
            return .empty()
            
        case .closePopupView(let popupType):
            switch popupType {
            case .create(let title, let image):
                if let title {
                    Task {
                        do {
                            let item = ChattingRoomItem(title: title, 
                                                        image: image,
                                                        maker: currentState.userCYO?.id ?? "",
                                                        people: [currentState.userCYO?.id ?? ""],
                                                        updated_at: Date(),
                                                        active_participation_code: GlobalFunctions.GenerateUniqueRandomCode())
                            
                            let status = try await ChattingListManager.shared.addChattingTable(item: item)
                            
                            if status == 201 {
                                Log.cyo("채팅방 생성 성공")
                            } else {
                                Log.cyo("채팅방 생성 실패 \(status)")
                                GlobalFunctions.showToast(message: "채팅방 생성 실패하였습니다.")
                            }
                        } catch {
                            Log.cyo("채팅방 생성 error \(error.localizedDescription)")
                            GlobalFunctions.showToast(message: "채팅방 생성 실패하였습니다.")
                        }
                    }
                    Log.kkr("방 만들기 팝업 닫기 & 만든 방으로 참여하기 - 방 이름: \(title)")
                    return .concat([
                        .just(Mutation.presentCreateRoomPopup(false)),
                        .just(Mutation.enterChattingRoom(title))
                    ])
                } else {
                    Log.cyo("없음")
                    return .just(Mutation.presentCreateRoomPopup(false))
                }
                
            case .join:
                return .just(Mutation.presentJoinRoomPopup(false, nil))
            }
            
        case .successJoinChattingRoom(let title):
            Log.kkr("successJoinChattingRoom is called - title: \(title)")
            return .just(.enterChattingRoom(title))
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
            
        case .presentCreateRoomPopup(let isPresent):
            newState.isPresentCreateRoomPopup = isPresent
            
        case .presentJoinRoomPopup(let isPresent, let code):
            newState.isPresentJoinRoomPopup = isPresent
            if let code = code {
                newState.joinCode = code
            } else {
                newState.joinCode = nil
            }
            
        case .enterChattingRoom(let roomTitle):
            newState.chatRoomTitle = roomTitle
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
    case create(title: String?, image: String?)
    case join
}
