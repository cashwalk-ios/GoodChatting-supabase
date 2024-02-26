//
//  ParticipationCodeReactor.swift
//  GoodChatting
//
//  Created by Rocky on 1/30/24.
//

import ReactorKit

final class ParticipationCodeReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var activeParticipationCode: String
    }
    
    let initialState: State
    
    init(activeParticipationCode: String) {
        self.initialState = State(activeParticipationCode: activeParticipationCode)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
