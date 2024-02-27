//
//  AuthManager.swift
//  GoodChatting
//
//  Created by 김광록 on 1/27/24.
//

import Foundation
import Supabase

class AuthManager {
    
    private init() {}

    static let shared = AuthManager()
    
    // MARK: - Properties
    
    let client = SupabaseClient(supabaseURL: URL(string: Constants.SUPABASE_PROJECT_URL)!, supabaseKey: Constants.SUPABASE_API_KEY)
    
    // MARK: - Functions
    
    /// 로그인되어 있는지 확인
    func getCurrentSession() async throws -> UserCYO? {
        do {
            let session = try await client.auth.session
            return UserCYO(id: session.user.id.uuidString, email: session.user.email)
        } catch {
            Log.kkr("현재 세션 불러오기 실패: \(error)")
            return nil
        }
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws -> UserCYO {
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
        Log.kkr("애플 로그인 성공 - userId: \(session.user.id.uuidString)")
        return UserCYO(id: session.user.id.uuidString, created_at: Date(), room_ids: nil, email: session.user.email)
    }
    
    func signInWithGoogle(idToken: String, nonce: String) async throws -> UserCYO {
        let session = try await client.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(
            provider: .google,
            idToken: idToken,
            nonce: nonce)
        )
        return UserCYO(id: session.user.id.uuidString, created_at: Date(), room_ids: nil, email: session.user.email)
    }
    
    func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            Log.kkr("로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    /// userCYO 테이블에 userId가 비어있는지 체크
    func selectUserIdFromUserCYO(userId: String) async throws -> Bool {
        let response: [UserCYO] = try await client.database
            .from("userCYO")
            .select("id")
            .eq("id", value: userId)
            .execute()
            .value
        
        Log.kkr("response: \(response)")
        return response.isEmpty
    }
    
}
