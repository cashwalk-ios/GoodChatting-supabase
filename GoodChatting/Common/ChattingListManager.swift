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
    
    func subcribeChannelRoom(userId: String) async throws {
        Log.cyo("subcribeChannelRoom(userId: \(userId))")
        let channel = await supabase.realtimeV2.channel("public:roomCYO")
        let changes = await channel.postgresChange(AnyAction.self, table: "roomCYO")
        
        await channel.subscribe()
        
        for await change in changes {
            handleChangedRoom(change, userId: userId)
        }
    }
    
    private func handleChangedRoom(_ action: AnyAction, userId: String) {
        switch action {
        case let .insert(action):
            let recode = action.record
            Log.cyo("V2 insert recode \(recode)")
            if let people = recode["people"]?.arrayValue,
               people.contains(where: { $0.stringValue ?? "" == userId }),
               let roomId = recode["id"]?.intValue {
                Log.cyo("채팅방 가져와랏!")
                
                let randomCode = arc4random_uniform(1000)   //TODO: 랜덤 닉네임 처리
                
                Task { [weak self] in
                    do {
                        try await self?.updateUserRoom(userId: userId, roomId: roomId)
                        try await self?.addUserNickname(userId: userId, roomId: roomId, nickName: "유저#\(randomCode)")
                        try await self?.getChattingList(userId: userId)
                    } catch {
                        Log.cyo("handleChangedRoom insert error \(error.localizedDescription)")
                    }
                }
            }
        case let .update(action):
            let recode = action.record
            Log.cyo("V2 update recode \(recode)")
            if let people = recode["people"]?.arrayValue, people.contains(where: { $0.stringValue ?? "" == userId }) {
                Log.cyo("채팅방 리스트만 갱신")
                
                Task { [weak self] in
                    do {
                        try await self?.getChattingList(userId: userId)
                    } catch {
                        Log.cyo("handleChangedRoom update error \(error.localizedDescription)")
                    }
                }
            }
               
        case let .delete(action):
            let recode = action.oldRecord
            Log.cyo("V2 delete recode \(recode)")
            if let id = recode["id"]?.intValue, userRoomList.contains(where: { $0.id == id }) {
                Task { [weak self] in
                    do {
                        try await self?.getChattingList(userId: userId)
                    } catch {
                        Log.cyo("handleChangedRoom update error \(error.localizedDescription)")
                    }
                }
            }
        default:
            break
        }
    }
    
    func getoutRoom(userId: String, roomData: ChattingList) {
        if (roomData.maker ?? "") == userId {
            // 방 생성자 -> 방 폭파
            // 방에 참여한 모든 데이터 삭제
            // 메시지 삭제 : newmessageCYO
            // 사람 삭제 : roomUserCYO
            // 방 삭제 : roomCYO
            Log.cyo("방 폭파")
            Task {
                do {
                    try await deleteMessageInRoom(roomId: roomData.id)
                    try await deleteNicknameInRoom(roomId: roomData.id)
                    try await deleteRoom(item: roomData)
                } catch {
                    Log.cyo("getoutRoom maker User error \(error.localizedDescription)")
                }
            }
            
        } else {
            // 일반 참가자 -> 방 나가기
            Log.cyo("방 나가기")
            Task {
                do {
                    try await deleteUserRoom(userId: userId, roomId: roomData.id)
                    if let item = roomData.roomUserCYO?.first(where: { $0.user_id ?? "" == userId }) {
                        try await deleteUserNickName(item: item)
                    }
                    try await deleteUserInRoom(userId: userId, item: roomData)
                    try await getChattingList(userId: userId)
                } catch {
                    Log.cyo("getoutRoom normal User error \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getChattingList(userId: String) async throws {
        Log.cyo("getChattingList")
        
        let list: [ChattingList] = try await supabase.database
            .from("roomCYO")
            .select(
            """
                *,
                newmessageCYO (
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
    
    func getCurrentChatRoomDetails(userId: String, roomId: Int) async throws -> [ChattingList] {
        Log.rk("getCurrentChatRoomDetails")
        
        let data: [ChattingList] = try await supabase.database
            .from("roomCYO")
            .select(
            """
                *,
                roomUserCYO (
                    *
                )
            """
            )
        
            .contains("people", value: [userId])    // 내가 참여한 방의 정보만 가져오기 ver.유저ID
            .eq("id", value: roomId)    // 내가 입장한 방의 정보만 가져오기
            .execute()
            .value

        return data
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
    
    func deleteRoom(item: ChattingList) async throws {
        Log.cyo("deleteRoom(item: \(item))")
        
        let response = try await supabase
            .database
            .from("roomCYO")
            .delete()
            .eq("id", value: item.id)
            .execute()
        
        Log.cyo("response = \(response)")
    }
    
    func deleteUserInRoom(userId: String, item: ChattingList) async throws {
        Log.cyo("deleteUserInRoom(userId: \(userId), item: \(item))")
        
        var temp = item
        temp.people?.removeAll(where: { $0 == userId })
        temp.roomUserCYO = nil
        temp.newmessageCYO = nil
        temp.updated_at = Date()
        
        let response = try await supabase
            .database
            .from("roomCYO")
            .update(temp)
            .eq("id", value: temp.id)
            .execute()
        
        Log.cyo("response = \(response)")
    }
    
    func deleteChattingRoomInDatabase(roomId: Int) async throws {
        Log.cyo("deleteChattingRoomInDatabase(roomId: \(roomId))")
    }
    
    // userCYO: 유저 테이블 룸ID 추가
    func updateUserRoom(userId: String, roomId: Int) async throws {
        Log.cyo("updateUserRoom(roomId: \(roomId))")
        
        var roomIds = userRoomList.compactMap({ $0.id })
        roomIds.append(roomId)
        
        let response = try await supabase
            .database
            .from("userCYO")
            .update(["room_ids": roomIds])
            .eq("id", value: userId)
            .execute()
        
        Log.cyo("response \(response)")
    }
    
    func deleteUserRoom(userId: String, roomId: Int) async throws {
        Log.cyo("deleteUserRoom(roomId: \(roomId))")
        
//        let roomIds = userRoomList.filter({ $0.id != roomId }).compactMap({ $0.id })
        var tempList = userRoomList
        tempList.removeAll(where: { $0.id == roomId })
        let roomIds = tempList.compactMap({ $0.id })
        
        let response = try await supabase
            .database
            .from("userCYO")
            .update(["room_ids": roomIds])
            .eq("id", value: userId)
            .execute()
        
        Log.cyo("response \(response)")
    }
    
    // roomUserCYO: 유저 닉네임 테이블 추가
    func addUserNickname(userId: String, roomId: Int, nickName: String) async throws {
        Log.cyo("addUserNickname(userId: \(userId), roomId: \(roomId), nickName: \(nickName))")
        
        let item = AddRoomUserCYOModel(room_id: roomId, user_id: userId, nickname: nickName)
        
        let response = try await supabase
            .database
            .from("roomUserCYO")
            .insert(item)
            .execute()
        
        Log.cyo("response \(response)")
    }
    
    // roomUserCYO : 해당 방에 포함된 모든 닉네임 아이템 삭제
    func deleteNicknameInRoom(roomId: Int) async throws {
        Log.cyo("deleteNicknameInRoom(roomId: \(roomId))")
        
        let response = try await supabase
            .database
            .from("roomUserCYO")
            .delete()
            .eq("room_id", value: roomId)
            .execute()
        
        Log.cyo("response \(response)")
    }
    
    // roomUserCYO: 방 나가기 후 해당 방에서 사용하고 있던 닉네임 아이템 삭제
    func deleteUserNickName(item: RoomUserCYO) async throws {
        Log.cyo("deleteUserNickName(item: \(item))")
        
        let response = try await supabase
            .database
            .from("roomUserCYO")
            .delete()
            .eq("id", value: item.id)
            .execute()
        
        Log.cyo("response \(response)")
    }
    
    // newmessageCYO : 해당 방에 포함된 모든 메시지 아이템 삭제
    func deleteMessageInRoom(roomId: Int) async throws {
        Log.cyo("deleteMessageInRoom(roomId: \(roomId))")
        
        let response = try await supabase
            .database
            .from("newmessageCYO")
            .delete()
            .eq("room_id", value: roomId)
            .execute()
        
        Log.cyo("response \(response)")
    }
    
    func selectRoom(roomTitle: String) async throws -> [ChattingList] {
        let response: [ChattingList] = try await supabase
            .database
            .from("roomCYO")
            .select("*")
            .eq("title", value: roomTitle)
            .execute()
            .value
        
        return response
    }
}
