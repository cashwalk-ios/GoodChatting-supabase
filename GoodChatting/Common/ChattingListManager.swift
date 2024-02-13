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
    
    func subcribeChannel() {
        Log.cyo("subcribeChannel")
        
        supabase.realtime.connect()
        
        //TODO: 내가 속해있는 방에서 일어나는 이벤트만 구독하도록 설정이 필요.
        let publicSchema = supabase.realtime.channel("public")
          .on("postgres_changes", filter: ChannelFilter(event: "sync", schema: "public")) { insertData in
              let insertValue = insertData.payload
              let data = insertValue["data"] as? [String: Any] ?? [:]
              let record = data["record"] as? [String: Any] ?? [:]
//              let title record["title"] as? String ?? "흠 오류가 났다."
              
              Log.cyo("inserts \(record)")
              
              Task { [weak self] in
                  try await self?.getChattingList()
              }
          }
          .on("postgres_changes", filter: ChannelFilter(event: "UPDATE", schema: "public")) {
              Log.cyo("updates \($0)")
          }
          .on("postgres_changes", filter: ChannelFilter(event: "DELETE", schema: "public")) {
              Log.cyo("delete \($0)")
          }
        
        publicSchema.onError { _ in Log.cyo("ERROR") }
        publicSchema.onClose { _ in Log.cyo("Closed gracefully") }
        publicSchema
            .subscribe { state, _ in
                switch state {
                case .subscribed:
                    Log.cyo("OK")
                case .closed:
                    Log.cyo("CLOSED")
                case .timedOut:
                    Log.cyo("Timed out")
                case .channelError:
                    Log.cyo("ERROR")
                }
            }
    }
    
    func getChattingList() async throws {
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
            .in("id", value: [1,3])                     // 내가 참여한 방의 정보만 가져오기
            .order("updated_at", ascending: false)      // 최신순으로 정렬
            .execute()
            .value
        
        Log.cyo("list \(list)")
        
        subject.onNext(.getList(list))
    }
    
    func addChattingTable(item: ChattingRoomItem) async throws {
        // id, createdAt, 
        Log.cyo("addChattingTable(item: \(item))")
        
        let response = try await supabase
            .database
            .from("roomCYO")
            .insert(item)
            .execute()
        
        Log.cyo("addChattingTable response \(response.status)")
    }
    
    func deleteChattingRoomInDatabase(roomId: Int) async throws {
        Log.cyo("deleteChattingRoomInDatabase(roomId: \(roomId))")
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
