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

final class LoginViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var loginView: LoginView!
    
    weak var sceneDelegate: SceneDelegate?
    private var kakaoLoginImage: UIImageView!

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
    
    @objc private func imageViewTapped() {
        print("카카오 로그인 이미지 탭...")
        loginWithKakao()
        // FIXME: 아래 처리 로그인 완료 이후에 해줄 것
//        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
//        DispatchQueue.main.async { [weak self] in
//            self?.sceneDelegate?.navigateToHome()
//        }
    }
    
    private func loginWithKakao() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    
                    //do something
                    _ = oauthToken
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
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let reactor = HomeReactor()
                owner.sceneDelegate?.navigateToHome(reactor: reactor)
    
                // FIXME: 아래 처리 로그인 완료 이후에 해줄 것
                UserSettings.isLoggedIn = true
                
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
