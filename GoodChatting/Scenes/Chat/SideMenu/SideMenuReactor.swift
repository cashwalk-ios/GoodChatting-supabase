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
                // Supabase 닉네임 변경 로직
                guard let userId = UserSettings.userId else { return .empty() }
                
                return Observable.create { [weak self] observer in
                    guard let self else {
                        observer.onCompleted()
                        return Disposables.create()
                    }
                    
                    Task {
                        do {
                            guard let name, let roomId = self.currentState.chattingInfo.first?.id else {
                                observer.onNext(.presentEditNamePopup(false))
                                return
                            }
                            if let matchingRoomUserCYO = self.currentState.chattingInfo.first?.roomUserCYO?
                                .first(where: { $0.user_id == userId }) {
                                let status = try await ChattingListManager.shared.changeNickname(changedName: name, roomUserData: matchingRoomUserCYO)
                                
                                if status == 200 {
                                    Log.rk("닉네임 변경 성공")
                                    // 닉네임 변경 성공 후 채팅 정보 다시 가져오기
                                    let data = try await ChattingListManager.shared.getCurrentChatRoomDetails(userId: userId, roomId: roomId)
                                    observer.onNext(.setChattingInfo(data))
                                    GlobalFunctions.showToast(message: "닉네임이 변경되었습니다.")

                                } else {
                                    Log.rk("닉네임 변경 실패 status is \(status)")
                                    GlobalFunctions.showToast(message: "닉네임 변경을 실패하였습니다.")
                                }
                            } else {
                                Log.rk("일치하는 사용자 ID를 찾을 수 없음")
                            }
                            
                            observer.onNext(.presentEditNamePopup(false)) // 팝업 닫기
                            observer.onCompleted()
                        } catch {
                            Log.rk("닉네임 변경 Error \(error.localizedDescription)")
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
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
