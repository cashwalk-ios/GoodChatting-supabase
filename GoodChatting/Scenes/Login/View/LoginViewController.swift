//
//  LoginViewController.swift
//  GoodChatting
//
//  Created by 김광록 on 1/11/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Supabase
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit
import RxGesture
import GoogleSignIn

final class LoginViewController: BaseViewController, View {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    private var loginView: LoginView!
    private let signInApple = SignInWithApple()
    private let signInGoole = SignInWithGoogle()
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
    }
    
    deinit {
        Log.rk("LoginVC is deinit!!")
    }
    
    // MARK: - Functions
    
    func bind(reactor: LoginReactor) {
        guard self.isViewLoaded else { return }
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    private func signInWithApple() async throws -> UserCYO {
        let appleResult = try await signInApple.startSignInWithAppleFlow()
        return try await AuthManager.shared.signInWithApple(idToken: appleResult.idToken, nonce: appleResult.nonce)
    }
    
    private func signInWithGoogle() async throws -> UserCYO {
        let googleResult = try await signInGoole.startSignInWithGoogleFlow()
        return try await AuthManager.shared.signInWithGoogle(idToken: googleResult.idToken, nonce: googleResult.nonce)
    }

    private func checkAlreadySignedInUser(_ user: UserCYO) async throws {
        // 이미 추가된 유저인지 조회
        let selectUserCount = try await AuthManager.shared.client.database
            .from("userCYO")
            .select("id", head: true, count: .exact)
            .eq("id", value: user.id)
            .execute()
            .count
        
        if selectUserCount == 0 {
            // 기존 유저가 아니면 Supabase UserCYO에 유저 추가
            let insertResponse = try await AuthManager.shared.client.database
                .from("userCYO")
                .insert(user)
                .execute()
        } else {
            // 기존 유저이면 Update data
            let updateResponse = try await AuthManager.shared.client.database
                .from("userCYO")
                .update(user)
                .eq("id", value: user.id)
                .execute()
        }
    }
}

// MARK: - Bind

extension LoginViewController {
    
    private func bindAction(reactor: LoginReactor) {
        loginView.appleLoginBoxView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self, onNext: { owner, _ in
                Task {
                    do {
                        // 애플 로그인
                        let user = try await owner.signInWithApple()
                        Log.kkr("uid: \(user.id), email: \(String(describing: user.email))")
                        try await owner.checkAlreadySignedInUser(user)
                        owner.sceneDelegate?.navigateToHome()
                    } catch {
                        owner.showToast(message: "애플 로그인 실패")
                    }
                }
            }).disposed(by: disposeBag)
        
        self.loginView.googleLoginBoxView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self, onNext: { owner, _ in
                owner.showToast(message: "준비 중입니다.")
//                Task {
//                    do {
//                        let userInfo = try await owner.signInWithGoogle()
//                        Log.kkr("uid: \(userInfo.uid), email: \(userInfo.email)")
//                    } catch {
//                        owner.showToast(message: "구글 로그인 실패")
//                    }
//                }
            }).disposed(by: disposeBag)
    }
    
    private func bindState(reactor: LoginReactor) {
        
    }
    
}

// MARK: - Layout

extension LoginViewController {
    
    private func setView() {
        self.loginView = LoginView().then {
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
}
