//
//  HomeReactor.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import ReactorKit

final class HomeReactor: Reactor {
    
    enum Action {
        case chattingAddAction(ChattingAddPopup.ChattingAddPopupAction)
        case settingAction(HomeViewController.SettingAction)
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .chattingAddAction(let action):
            switch action {
            case .makeRoom:
                Log.cyo("makeRoom")
                return .empty()
            case .joinRoom:
                Log.cyo("joinRoom")
                return .empty()
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
