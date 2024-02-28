//
//  SideMenuReactor.swift
//  GoodChatting
//
//  Created by Rocky on 2/22/24.
//

import Foundation
import ReactorKit
import Supabase

final class SideMenuReactor: Reactor {
    
    enum Action {
        case fetchChattingInfo(roomId: Int)
        case getOutChattingRoom(item: ChattingList?)
        
        case closePopupView(type: EditNamePopupType)
    }
    
    enum Mutation {
        case setChattingInfo([ChattingList])
        case presentEditNamePopup(Bool)
    }
    
    struct State {
        var chattingInfo: [ChattingList] = []
        var isPresentEditNamePopup: Bool = false
    }
    
    var initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .fetchChattingInfo(let roomId):
                guard let userId = UserSettings.userId else { return .empty() }
            
                return Observable.create { observer in
                    Task {
                        do {
                            let data = try await ChattingListManager.shared.getCurrentChatRoomDetails(userId: userId, roomId: roomId)
                            observer.onNext(.setChattingInfo(data))
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            
        case .getOutChattingRoom(let item):
            if let item {
                ChattingListManager.shared.getoutRoom(userId: UserSettings.userId ?? "", roomData: item)
            }
            
            return .empty()
            
        case .closePopupView(let popUpType):
            switch popUpType {
            case .change(let name):
                // TODO: - Supabase 닉네임 변경 로직
                Log.rk("닉네임 변경하기 버튼 클릭됨")
                return .just(.presentEditNamePopup(false))
            case .close:
                return .just(.presentEditNamePopup(false))
            }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .setChattingInfo(let data):
            newState.chattingInfo = data
            
        case .presentEditNamePopup(let isPresent):
            newState.isPresentEditNamePopup = isPresent
        }
        
        return newState
    }
    
}

enum EditNamePopupType {
    case change(name: String?)
    case close
}
