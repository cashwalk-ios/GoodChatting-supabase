//
//  LoginView.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import UIKit
import SnapKit
import Then

final class LoginView: UIView {
    
    // MARK: - Properties
    
    var googleLoginBoxView: UIView!
    var kakaoLoginBoxView: UIView!
    var appleLoginBoxView: UIView!
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .designColor(color: .white())
        self.setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers

    
}

// MARK: - Layout

extension LoginView {
    
    private func setView() {
        
        let GCImageView = UIImageView().then {
            $0.image = UIImage(named: "launch-icon")
            self.addSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(64)
                make.top.equalToSuperview().offset(259)
                make.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "Good Chatting"
            $0.textColor = .designColor(color: .black())
            $0.font = .appleSDGothicNeo(.bold, size: 33)
            self.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(GCImageView.snp.bottom).offset(25)
                make.centerX.equalToSuperview()
            }
        }
        
        setupLoginViews()
        
    }
    
    fileprivate func setupLoginViews() {
        self.googleLoginBoxView = UIView().then {
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .white //.init(hexCode: "F0F0F0")
            $0.isUserInteractionEnabled = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.black.cgColor
            self.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
                make.left.right.equalToSuperview().inset(25)
                make.bottom.equalToSuperview().inset(64)
            }
        }
        
        _ = UIImageView().then {
            $0.image = UIImage(named: "iconGoogleSns")
            googleLoginBoxView.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.size.equalTo(26)
                make.left.equalToSuperview().inset(22)
                make.centerY.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "Google로 로그인"
            $0.font = .appleSDGothicNeo(.regular, size: 18)
            $0.textColor = .black
            googleLoginBoxView.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
        self.appleLoginBoxView = UIView().then {
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .white
            $0.isUserInteractionEnabled = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.black.cgColor
            self.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
                make.left.right.equalToSuperview().inset(25)
                make.bottom.equalTo(googleLoginBoxView.snp.top).offset(-12)
            }
        }
        
        _ = UIImageView().then {
            $0.image = UIImage(systemName: "apple.logo")
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .black
            
            appleLoginBoxView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(32)
                make.left.equalToSuperview().inset(20)
                make.centerY.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "Apple로 로그인"
            $0.font = .appleSDGothicNeo(.regular, size: 18)
            $0.textColor = .black
            
            appleLoginBoxView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
    }
}
