//
//  LoginReactor.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import ReactorKit

final class LoginReactor: Reactor {
    
    enum Action {
        case tappedKakaoLoginButton
    }
    
    enum Mutation {
        case successLogin
    }
    
    struct State {
        var isLoggedIn: Bool = false
    }
    
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tappedKakaoLoginButton:
            return .just(.successLogin)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .successLogin:
            newState.isLoggedIn = true
        }
        
        return newState
    }
}
