//
//  ChatReactor.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 1/23/24.
//

import Foundation
import ReactorKit
import Supabase

final class ChatReactor: Reactor {
    
    private var channel: RealtimeChannelV2!
    private var client = ChattingListManager.shared.supabase
    
    enum Action {
        case fetchChatData
    }
    
    enum Mutation {
        case mutateChat([ChatMessageModel])
    }
    
    struct State {
        var chattingRoomTitle: String = ""
        var roomPeopleCount: Int = 10
        var chatList: [ChatMessageModel] = []
        
        var roomData: ChattingList
    }
    
    var initialState: State// = State()
    
    init(roomTitle: String, roomData: ChattingList) {
        initialState = State(chattingRoomTitle: roomTitle, roomData: roomData)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchChatData:
            
            return Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        self.channel = await self.client.realtimeV2.channel("1")
                        await self.channel.subscribe()
                        await self.subscribeBroadcast()
                        let database = await self.fetchDatabase()
                        observer.onNext(.mutateChat(database))
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
       
        var state = state
        
        switch mutation {
        case .mutateChat(let array):
            state.chatList = array
        }
        
        return state
    }
    
}

extension ChatReactor {
    
    @MainActor
    private func subscribeBroadcast() async {
        Task {
            for await event in await channel.broadcast(event: "broadcastEventName") {
                guard let payload = event["payload"] else {
                    print("no payload")
                    return
                }
                
                switch payload {
                case .object(let jsonObject):
                    
                    break
//                    ChatMessageModel
                    
//                    let message = Message(jsonObject: jsonObject)
//                    self.messages.append(message)
                default:
                    return
                }
            }
        }
    }
    
    @MainActor
    private func fetchDatabase() async -> [ChatMessageModel] {
        do {
            let messages: [ChatMessageModel] = try await client.database
                .from("messageCYO")
                .select()
//                .eq("eventId", value: "eventId")
                .execute()
                .value
            
//            Log.cyo(messages)
//            self.messages = messages.sorted(by: { $0.createdAt < $1.createdAt })
            return messages
        } catch let error {
            print(error.localizedDescription)
        }
        
        return []
    }
}
