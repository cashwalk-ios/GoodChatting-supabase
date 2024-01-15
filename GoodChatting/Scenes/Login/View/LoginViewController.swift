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

final class LoginViewController: BaseViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var loginView: LoginView!

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
    
    private func loginWithKakao() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let error = error {
                    let alert = GlobalFunctions.makeAlert(message: error.localizedDescription, firstActionMsg: "확인")
                    self?.present(alert, animated: true)
                }
                else {
                    Log.kkr("로그인 성공 - oauthToken: \(String(describing: oauthToken))")
                    let reactor = HomeReactor()
                    self?.sceneDelegate?.navigateToHome(reactor: reactor)
                    UserSettings.isLoggedIn = true
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                if let error = error {
                    let alert = GlobalFunctions.makeAlert(message: error.localizedDescription, firstActionMsg: "확인")
                    self?.present(alert, animated: true)
                }
                else {
                    Log.kkr("로그인 성공 - oauthToken: \(String(describing: oauthToken?.accessToken))")  /// oauthToken: Optional("QYxrN_mOdmQtnUy3IqYZg-PV1nDMMerjkHwKKwzTAAABjQp60RyUJG13ldIf8A")
                    let reactor = HomeReactor()
                    self?.sceneDelegate?.navigateToHome(reactor: reactor)
                    UserSettings.isLoggedIn = true
                }
            }
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
                owner.loginWithKakao()
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
