//
//  SignInWithApple.swift
//  GoodChatting
//
//  Created by 김광록 on 1/27/24.
//

import Foundation
import CryptoKit
import AuthenticationServices

struct SignInAppleResult {
    let idToken: String
    let nonce: String
}

class SignInWithApple: NSObject {
    
    fileprivate var currentNonce: String?
    private var completionHandler: ((Result<SignInAppleResult, Error>) -> Void)?
    private var signInContinuation: CheckedContinuation<SignInAppleResult, Error>?

    func startSignInWithAppleFlow() async throws -> SignInAppleResult {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.signInContinuation = continuation
            self?.signInWithAppleFlow()
        }
    }

//    func startSignInWithAppleFlow() async throws -> SignInAppleResult {
//        return try await withCheckedThrowingContinuation { continuation in
//            self.signInWithAppleFlow { result in
//                switch result {
//                case .success(let appleResult):
//                    continuation.resume(returning: appleResult)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }   
//    }
    
    private func signInWithAppleFlow() {
        DispatchQueue.main.async {
            guard let topVC = UIApplication.getMostTopViewController() else {
                return
            }
            
            let nonce = self.randomNonceString()
            self.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = GlobalFunctions.sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = topVC
            authorizationController.performRequests()
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
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
}

extension SignInWithApple: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor(frame: .zero)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                Log.kkr("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                Log.kkr("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                Log.kkr("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let appleResult = SignInAppleResult(idToken: idTokenString, nonce: nonce)
            signInContinuation?.resume(returning: appleResult)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        signInContinuation?.resume(throwing: error)
    }
    
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}
