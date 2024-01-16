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
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit
import RxGesture

import Supabase
import AuthenticationServices

final class LoginViewController: BaseViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var loginView: LoginView!
    
    let supabase = SupabaseClient(supabaseURL: URL(string: Constants.SUPABASE_PROJECT_URL)!,
                                supabaseKey: Constants.SUPABASE_API_KEY)

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
    
    
    
    
//    private func loginWithKakao() {
//        if (UserApi.isKakaoTalkLoginAvailable()) {
//            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
//                guard let self else { return }
//                if let error = error {
//                    let alert = GlobalFunctions.makeAlert(message: error.localizedDescription, firstActionMsg: "확인")
//                    self.present(alert, animated: true)
//                }
//                else {
//                    Log.kkr("로그인 성공 - oauthToken: \(String(describing: oauthToken))")
//                    self.sceneDelegate?.navigateToHome(from: self, animated: true)
//                    UserSettings.isLoggedIn = true
//                }
//            }
//        } else {
//            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
//                guard let self else { return }
//                if let error = error {
//                    let alert = GlobalFunctions.makeAlert(message: error.localizedDescription, firstActionMsg: "확인")
//                    self.present(alert, animated: true)
//                }
//                else {
//                    Log.kkr("로그인 성공 - oauthToken: \(String(describing: oauthToken?.accessToken))")  /// oauthToken: Optional("QYxrN_mOdmQtnUy3IqYZg-PV1nDMMerjkHwKKwzTAAABjQp60RyUJG13ldIf8A")
//                    self.sceneDelegate?.navigateToHome(from: self, animated: true)
//                    UserSettings.isLoggedIn = true
//                }
//            }
//        }
    //    }
    
//    func startLoginFlow() {
//
//        let state = UUID().uuidString
//        
//        // State 값을 로컬에 저장하여 나중에 검증할 수 있도록 함
//        UserDefaults.standard.set(state, forKey: "oauthState")
//        
//        guard let authURL = URL(string: "https://kauth.kakao.com/oauth/authorize?client_id=\(Constants.KAKAO_CLIENT_ID)&redirect_uri=\(Constants.KAKAO_REDIRECT_URL)&response_type=code&state=\(state)") else { return }
//        
//        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: try! KakaoSDK.shared.scheme()) { [weak self] callbackURL, error in
//                guard let self = self, error == nil, let callbackURL = callbackURL else { return }
//
//                let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
//                if let code = queryItems?.first(where: { $0.name == "code" })?.value {
//                    self.exchangeCodeForToken(code: code, callbackURL: callbackURL)
//                }
//            }
//            session.presentationContextProvider = self
//            session.start()
//    }
//    
//    func exchangeCodeForToken(code: String, callbackURL: URL) {
//        // 인증 응답에서 받은 state 값을 검증
//        guard let receivedState = URLComponents(string: callbackURL.absoluteString)?.queryItems?.first(where: { $0.name == "state" })?.value,
//              let savedState = UserDefaults.standard.string(forKey: "oauthState"),
//              receivedState == savedState else {
//            print("State 값이 일치하지 않습니다. CSRF 공격 가능성이 있습니다.")
//            return
//        }
//
//        // State 값 일치 확인 후, 토큰 요청 로직 계속
//        let tokenURL = URL(string: "https://kauth.kakao.com/oauth/token")!
//        var request = URLRequest(url: tokenURL)
//        request.httpMethod = "POST"
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        let body = "grant_type=authorization_code&client_id=\(Constants.KAKAO_CLIENT_ID)&redirect_uri=\(Constants.KAKAO_REDIRECT_URL)&code=\(code)"
//        request.httpBody = body.data(using: .utf8)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else { return }

//        }
//        task.resume()
//    }


    
    private func loginWithSupabaseKakao() async {
        Log.rk("loginWithSupabaseKakao 메서드 실행")
        
        do {
            let url = try await supabase.auth.getOAuthSignInURL(provider: .kakao)
            
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: try! KakaoSDK.shared.scheme()) { [weak self] url, error in
                guard let self else { return }
                guard let url else { return }
                
                Task {
                    do {
                        try await self.supabase.auth.session(from: url)
                    } catch {
                        Log.rk(error.localizedDescription)
                    }
                }
            }
            
            session.presentationContextProvider = self
            session.start()
            
        }  catch {
            Log.rk(error.localizedDescription)
        }

    }

}

// MARK: - Bind

extension LoginViewController {
    
    private func bindAction(reactor: LoginReactor) {
        self.loginView.kakaoLoginBoxView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self, onNext: { owner, _ in
                Log.kkr("로그인 버튼 탭...")
                Task {
                    await owner.loginWithSupabaseKakao()
                }
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

extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}

