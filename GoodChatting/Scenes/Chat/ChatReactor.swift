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
        case insertSubscribe
        case fetchChatData
        case sendMessage(text: String)
    }
    
    enum Mutation {
        case mutateChat([ChatMessageModel])
        case mutateRequestMessage
        case mutateReload(ChatMessageModel)
    }
    
    struct State {
        var chattingRoomTitle: String = ""
        var roomPeopleCount: Int = 10
        var chatList: [ChatMessageModel] = []
        
        var roomData: ChattingList
        var userData: UserCYO
    }
    
    var initialState: State
    
    init(roomTitle: String, roomData: ChattingList, userData: UserCYO) {
        initialState = State(chattingRoomTitle: roomTitle, roomData: roomData, userData: userData)
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
                        self.channel = await self.client.realtimeV2.channel("\(self.currentState.roomData.id)")
                        
                        _ = await self.channel.postgresChange(AnyAction.self, table: "newmessageCYO")
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
            
        case .insertSubscribe:
            
            return Observable.create { [weak self] observer in
                
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    
                    let channel = await self.client.realtimeV2.channel("public")
                    let action = await channel.postgresChange(AnyAction.self, table: "newmessageCYO")
                        
                    await channel.subscribe()
                    for await change in action {
                        do {
                            
                            switch change {
                            case .insert(let action):
                                if let id = action.record["id"]?.stringValue,
                                   let createAt = action.record["created_at"]?.stringValue,
                                   let roomId = action.record["room_id"]?.intValue,
                                   let userId = action.record["user_id"]?.stringValue,
                                   let message = action.record["message"]?.stringValue,
                                   let readUsers = action.record["read_users"]?.arrayValue as? [Int]? {
                                    
                                    let chatModel = ChatMessageModel(id: id,
                                                                     room_id: roomId,
                                                                     user_id: userId,
                                                                     message: message,
                                                                     read_users: readUsers,
                                                                     created_at: createAt)
                                    observer.onNext(.mutateReload(chatModel))
                                }
                            default: break
                            }
                            
                        } catch {
                            observer.onError(error)
                        }
                    }
                }
                
                return Disposables.create()
            }
        case .sendMessage(let message):
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
            let inputTimestamp = dateformatter.string(from: Date())
            
            let roomId = currentState.roomData.id
            
            let item = ChatMessageModel(id: UUID().uuidString,
                                        room_id: roomId,
                                        user_id: currentState.userData.id,
                                        message: message,
                                        read_users: nil,
                                        created_at: inputTimestamp)
            
            return Observable.create { observer in
                
                Task {
                    do {
                        try await ChattingListManager.shared.supabase
                            .database
                            .from("newmessageCYO")
                            .insert(item)
                            .execute()
                        
                        try await ChattingListManager.shared.supabase
                            .database
                            .from("roomCYO")
                            .update(["updated_at": Date()])
                            .eq("id", value: roomId)
                            .execute()
                        
                        observer.onNext(.mutateRequestMessage)
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
        case .mutateRequestMessage: break
        case .mutateReload(let chatModel):
            state.chatList.append(chatModel)
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
            }
        }
    }
    
    @MainActor
    private func fetchDatabase() async -> [ChatMessageModel] {
        do {
            let messages: [ChatMessageModel] = try await client.database
                .from("newmessageCYO")
                .select()
                .equals("room_id", value: "\(currentState.roomData.id)")
                .execute()
                .value
            
            return messages.sorted(by: { $0.created_at < $1.created_at })
        } catch let error {
            print(error.localizedDescription)
        }
        
        return []
    }
}
