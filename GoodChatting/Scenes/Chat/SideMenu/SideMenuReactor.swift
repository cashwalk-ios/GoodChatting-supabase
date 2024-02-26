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
    }
    
    enum Mutation {
        case setChattingInfo([ChattingList])
    }
    
    struct State {
        var chattingInfo: [ChattingList] = []
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .setChattingInfo(let data):
            newState.chattingInfo = data
            
        }
        
        return newState
    }
    
}

extension SideMenuReactor {

}
