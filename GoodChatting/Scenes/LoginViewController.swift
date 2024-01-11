//
//  LoginViewController.swift
//  GoodChatting
//
//  Created by 김광록 on 1/11/24.
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
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
    
    @objc private func imageViewTapped() {
        print("카카오 로그인 이미지 탭...")
        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        kakaoLoginImage.addGestureRecognizer(tapGesture)
    }

}
