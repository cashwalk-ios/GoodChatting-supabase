//
//  LoginReactor.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import ReactorKit

final class LoginReactor: Reactor {
    
    enum Action {
        case tappedGoogleLoginButton
    }
    
    enum Mutation {
        case success
        case fail
    }
    
    struct State {
        var isLoggedIn: Bool = false
    }
    
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tappedGoogleLoginButton:
            // Google Login logic
            return .just(.success)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .success:
            newState.isLoggedIn = true
        case .fail:
            newState.isLoggedIn = false
        }
        
        return newState
    }
}
