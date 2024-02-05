//
//  CodeIssuanceHistoryReactor.swift
//  GoodChatting
//
//  Created by Rocky on 2/1/24.
//

import ReactorKit

final class CodeIssuanceHistoryReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        // var expiredCodeList: [ExpiredCodeList] = []
        var tempExpiredCodeList: [String] = [
            "g.sh/+3bNCRMGeF_3mOFU2",
            "g.sh/+6hBCXSGeF_4bOFU2",
            "g.sh/+8yKRWOEtIU_3dWRF9",
            "g.sh/+5rGXQCYtQZ_1dUGS2",
            "g.sh/+7nHUYVGeKJ_2fXRT3",
            "g.sh/+9mIVXDFtLQ_4gZSA4",
            "g.sh/+1oJWZEGuMP_5hTBV5",
            "g.sh/+2pKXYFHvNQ_6iUCW6",
            "g.sh/+4qLZYGIwOR_7jVDX7"
        ]

    }
    
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
