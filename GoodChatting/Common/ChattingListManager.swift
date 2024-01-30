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
    
    let supabase = SupabaseClient(supabaseURL: Constants.SUPABASE_PROJECT_URL, supabaseKey: Constants.SUPABASE_API_KEY)
    
    let subject = PublishSubject<ChattingListManagerAction>()
    
    init() { }
    
    func subcribeChannel() {
        Log.cyo("subcribeChannel")
        
        supabase.realtime.connect()
        
        //TODO: 내가 속해있는 방에서 일어나는 이벤트만 구독하도록 설정이 필요.
        let publicSchema = supabase.realtime.channel("public")
          .on("postgres_changes", filter: ChannelFilter(event: "INSERT", schema: "public")) { insertData in
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
    
    func addChattingTable(testNum: Int) async throws {
        Log.cyo("addChattingTable")
        
//        let addItem = ChattingList(title: "테스트\(testNum)",
//                         update_at: Date(),
//                         lastest: "무시하셔도되요\(testNum)",
//                         image: "template01",
//                         unRead: 10,
//                         number: 3)
//        
//        let response = try await supabase
//            .database
//            .from("roomCYO")
//            .insert(addItem)
//            .execute()
//                    
//        Log.cyo("response \(response.status)")
    }
}
