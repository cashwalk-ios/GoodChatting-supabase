//
//  ChatReactor.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 1/23/24.
//

import Foundation
import ReactorKit

final class ChatReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var chattingRoomTitle: String = ""
        var roomPeopleCount: Int = 10
        var testChatList: [String] = ["1"]
    }
    
    var initialState: State = State()
    
    init(roomTitle: String) {
        initialState = State(chattingRoomTitle: roomTitle)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
    
}
