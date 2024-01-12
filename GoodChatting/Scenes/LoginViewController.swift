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

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var sceneDelegate: SceneDelegate?
    private var kakaoLoginImage: UIImageView!

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupView()
        setGesture()
    }
    
    // MARK: - Functions
    
    private func setupProperties() {
        self.view.backgroundColor = .designColor(color: .secondGray())
    }

    private func setupView() {
        kakaoLoginImage = UIImageView().then {
            $0.image = UIImage(named: "kakao_login_large_wide")
            $0.contentMode = .scaleAspectFill
            $0.isUserInteractionEnabled = true
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            }
        }
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        kakaoLoginImage.addGestureRecognizer(tapGesture)
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
