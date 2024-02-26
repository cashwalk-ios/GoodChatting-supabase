//
//  ParticipationCodeReactor.swift
//  GoodChatting
//
//  Created by Rocky on 1/30/24.
//

import Foundation
import ReactorKit

final class ParticipationCodeReactor: Reactor {
    
    enum Action {
        case renewParticipationCode
    }
    
    enum Mutation {
        case setRenewedParticipationCode(String)
    }
    
    struct State {
        var roomId: Int
        var activeParticipationCode: String
    }
    
    let initialState: State
    
    init(roomId: Int, activeParticipationCode: String) {
        self.initialState = State(
            roomId: roomId, 
            activeParticipationCode: activeParticipationCode
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .renewParticipationCode:
            return Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let newParticipationCode = GlobalFunctions.GenerateUniqueRandomCode()
                        
                        try await ChattingListManager.shared.supabase
                            .database
                            .from("roomCYO")
                            .update(["active_participation_code": newParticipationCode])
                            .eq("id", value: self.currentState.roomId)
                            .execute()
                        
                        NotificationCenter.default.post(name: .participationCodetoSideMenuVC,
                                                        object: nil,
                                                        userInfo: ["newCode": newParticipationCode])

                        
                        observer.onNext(.setRenewedParticipationCode(newParticipationCode))
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                        Log.rk("Error is \(error)")
                    }
                }
                return Disposables.create()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setRenewedParticipationCode(let newParticipationCode):
            newState.activeParticipationCode = newParticipationCode
        }
        
        return newState
    }
}
