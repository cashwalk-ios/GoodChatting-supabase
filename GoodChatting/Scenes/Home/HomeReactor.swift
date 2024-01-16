//
//  HomeReactor.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import ReactorKit
import UIKit

final class HomeReactor: Reactor {
    
    enum Action {
        case chattingAddAction(ChattingAddPopup.ChattingAddPopupAction)
        case settingAction(HomeViewController.SettingAction)
        case getChattingList
    }
    
    enum Mutation {
        case setChattingList
    }
    
    struct State {
        var chattingList: [ChattingListModel.ChattingList] = []
    }
    
    var initialState: State = State()
    
    init() {
        initialState = State(chattingList: getChattingListTemp())
    }
    
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
            
        case .getChattingList:
            //TODO: 아마 supabase 리얼타임 디비 구독하는 형태로 개발이 될 것으로 보임.
            return .just(.setChattingList)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setChattingList:
            newState.chattingList = getChattingListTemp() // 우선은 더미를 넣읍시당.
        }
        
        return newState
    }
    
    func getChattingListTemp() -> [ChattingListModel.ChattingList] {
        let jsonFileName = "ChattingListTempData"
        let extensionType = "json"
        
        guard let fileLocation = Bundle.main.url(forResource: jsonFileName, withExtension: extensionType) else { return [] }
        do {
            let jsonData = try Data(contentsOf: fileLocation)
            
            let decoder = JSONDecoder()
            let chattingListData = try decoder.decode(ChattingListModel.self, from: jsonData)
            Log.cyo("getChattingListTemp success")
            return chattingListData.list
        } catch {
            Log.cyo("getChattingListTemp error = \(error.localizedDescription)")
            return []
        }
    }
}
