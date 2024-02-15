//
//  ChattingListManager.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/17/24.
//

import Foundation
import Supabase
import ReactorKit
import CoreTelephony

class ChattingListManager {
    
    enum ChattingListManagerAction {
        case getList([ChattingList])
    }
    
    static let shared: ChattingListManager = ChattingListManager()
    
    let supabase = SupabaseClient(supabaseURL: URL(string: Constants.SUPABASE_PROJECT_URL)!, supabaseKey: Constants.SUPABASE_API_KEY)
    
    let subject = PublishSubject<ChattingListManagerAction>()
    
    init() { }
    
    func subcribeChannelV2() async throws {
        Log.cyo("subcribeChannelV2()")
        let channel = await supabase.realtimeV2.channel("public:roomCYO")
        let changes = await channel.postgresChange(AnyAction.self, table: "roomCYO")
        
//        let prenseces = await channel.presenceChange()
        
        await channel.subscribe()
        
//        let userId = try await supabase.auth.session.user.id
        
        for await change in changes {
            handleChangedUser(change, userId: "1")
        }
    }
    
    private func handleChangedUser(_ action: AnyAction, userId: String) {
        switch action {
        case let .insert(action):
            let recode = action.record
            Log.cyo("V2 insert recode \(recode)")
            if let people = recode["people"]?.arrayValue, people.contains(where: { $0.stringValue ?? "" == userId }) {
                Log.cyo("채팅방 가져와랏!")
                
                Task { [weak self] in
                    try await self?.getChattingList(userId: userId)
                }
            }
        case let .update(action):
            let recode = action.record
            Log.cyo("V2 update recode \(recode)")
        case let .delete(action):
            let recode = action.oldRecord
            Log.cyo("V2 delete recode \(recode)")
        default:
            break
        }
    }
    
    func getChattingList(userId: String) async throws {
        Log.cyo("getChattingList")
        
        let list: [ChattingList] = try await supabase.database
            .from("roomCYO")
            .select(
            """
                *,
                messageCYO (
                    *
                ),
                roomUserCYO (
                    *
                )
            """
            )
            .contains("people", value: ["1"])               // 내가 참여한 방의 정보만 가져오기 ver.유저ID
//            .in("people", value: [1])                     // 내가 참여한 방의 정보만 가져오기 ver.룸IDs
            .order("updated_at", ascending: false)      // 최신순으로 정렬
            .execute()
            .value
        
//        Log.cyo("list \(list)")
        
        subject.onNext(.getList(list))
    }
    
    func addChattingTable(item: ChattingRoomItem) async throws -> Int {
        // id, createdAt,
        Log.cyo("addChattingTable(item: \(item))")
        
        let response = try await supabase
            .database
            .from("roomCYO")
            .insert(item)
            .execute()
        
//        Log.cyo("addChattingTable response \(response)")
        
        return response.status
    }
    
    func deleteChattingRoomInDatabase(roomId: Int) async throws {
        Log.cyo("deleteChattingRoomInDatabase(roomId: \(roomId))")
    }
    
    func insertChatList() async throws {
        let item = ChatMessageModel(id: 6,
                                    room_id: 1,
                                    user_id: "1",
                                    message: "HI",
                                    read_users: nil,
                                    created_at: "")
        
        let response = try await supabase
            .database
            .from("messageCYO")
            .insert(item)
            .execute()
    }
}
