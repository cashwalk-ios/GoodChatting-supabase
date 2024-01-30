//
//  AuthManager.swift
//  GoodChatting
//
//  Created by 김광록 on 1/27/24.
//

import Foundation
import Supabase

struct UserInfo {
    let uid: String
    let email: String?
}

class AuthManager {
    
    private init() {}

    static let shared = AuthManager()
    
    // MARK: - Properties
    
    let client = SupabaseClient(supabaseURL: Constants.SUPABASE_PROJECT_URL, supabaseKey: Constants.SUPABASE_API_KEY)
    
    /// 로그인되어 있는지 확인
    func getCurrentSession() async throws -> UserInfo {
        let session = try await client.auth.session
        return UserInfo(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    // MARK: - Functions
    
    func signInWithApple(idToken: String, nonce: String) async throws -> UserInfo {
        Log.kkr("SignIn to Supabase")
        do {
            let session = try await client.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            ))
            Log.kkr("session: \(session)")
            return UserInfo(uid: session.user.id.uuidString, email: session.user.email)
        } catch {
            Log.kkr("Error SignIn to Supabase: \(error)")
            return UserInfo(uid: "", email: "")
        }
    }
    
    func signInWithGoogle(idToken: String, nonce: String) async throws -> UserInfo {
        let session = try await client.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(
            provider: .google,
            idToken: idToken,
            nonce: nonce)
        )
        return UserInfo(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
}
