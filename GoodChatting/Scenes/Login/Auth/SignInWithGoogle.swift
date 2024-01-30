//
//  SignInWithGoogle.swift
//  GoodChatting
//
//  Created by 김광록 on 1/29/24.
//

import GoogleSignIn
import CryptoKit

struct SignInGoogleResult {
    let idToken: String
    let nonce: String
}

class SignInWithGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void) {
        DispatchQueue.main.async {
            guard let topVC = UIViewController.topViewController() else {
                completion(.failure(NSError()))
                return
            }
            
            let nonce = self.randomNonceString()
            Log.kkr("Google's nonce: \(nonce)")
            
            GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { signInResult, error in
                guard let user = signInResult?.user, let idToken = user.idToken else {
                    topVC.showToast(message: "구글 로그인 실패: \((error?.localizedDescription) ?? "No error description")")
                    completion(.failure(NSError()))
                    return
                }
                
                Log.kkr("로그인 성공 - idToken: \(idToken.tokenString)")
                
                completion(.success(.init(idToken: idToken.tokenString, nonce: nonce)))
            }
        }
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }

}
