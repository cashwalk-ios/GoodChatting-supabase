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
    var userRoomList: [ChattingList] = []
    
    init() { }
    
    func subcribeChannelV2(userId: String) async throws {
        Log.cyo("subcribeChannelV2()")
        let channel = await supabase.realtimeV2.channel("public:roomCYO")
        let changes = await channel.postgresChange(AnyAction.self, table: "roomCYO")
        
        await channel.subscribe()
        
        for await change in changes {
            handleChangedUser(change, userId: userId)
        }
    }
    
    private func handleChangedUser(_ action: AnyAction, userId: String) {
        switch action {
        case let .insert(action):
            let recode = action.record
            Log.cyo("V2 insert recode \(recode)")
            if let people = recode["people"]?.arrayValue,
               people.contains(where: { $0.stringValue ?? "" == userId }),
               let roomId = recode["id"]?.intValue {
                Log.cyo("채팅방 가져와랏!")
                
                Task { [weak self] in
                    do {
                        try await self?.updateUserRoom(userId: userId, roomId: roomId)
                        try await self?.getChattingList(userId: userId)
                    } catch {
                        Log.cyo("뭔지모르지만 \(error.localizedDescription)")
                    }
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
            .contains("people", value: [userId])               // 내가 참여한 방의 정보만 가져오기 ver.유저ID
            .order("updated_at", ascending: false)      // 최신순으로 정렬
            .execute()
            .value
        
//        Log.cyo("list \(list)")
        
        userRoomList = list
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
    
    func updateUserRoom(userId: String, roomId: Int) async throws {
        Log.cyo("updateUserRoom(roomId: \(roomId))")
        
        var roomIds = userRoomList.compactMap({ $0.id })
        roomIds.append(roomId)
        
        let response = try await supabase
            .database
            .from("userCYO")
            .update(["room_ids" : roomIds])
            .eq("id", value: userId)
            .execute()
        
        Log.cyo("response \(response)")
    }
    
    func insertChatList() async throws {
        let item = ChatMessageModel(id: 6,
                                    room_id: 1,
                                    user_id: 1,
                                    message: "HI",
                                    read_users: nil)
        
        let response = try await supabase
            .database
            .from("messageCYO")
            .insert(item)
            .execute()
    }
}
