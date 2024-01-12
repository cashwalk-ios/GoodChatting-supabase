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
    
    var kakaoLoginBoxView: UIView!
    
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
            $0.snp.makeConstraints {
                $0.size.equalTo(64)
                $0.top.equalToSuperview().offset(259)
                $0.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "Good Chatting"
            $0.textColor = .designColor(color: .black())
            $0.font = .appleSDGothicNeo(.bold, size: 33)
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(GCImageView.snp.bottom).offset(49)
                $0.centerX.equalToSuperview()
            }
        }
        
        self.kakaoLoginBoxView = UIView().then {
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .init(hexCode: "FEE502")
            $0.isUserInteractionEnabled = true
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalTo(53)
                $0.left.right.equalToSuperview().inset(25)
                $0.bottom.equalToSuperview().offset(-64)
            }
        }
        
        let kakaoImageView = UIImageView().then {
            $0.image = UIImage(named: "iconKakaoSns")
            self.kakaoLoginBoxView.addSubview($0)
            $0.snp.makeConstraints {
                $0.size.equalTo(24)
            }
        }
        
        let kakaoLabel = UILabel().then {
            $0.text = "카카오로 로그인"
            $0.font = .appleSDGothicNeo(.regular, size: 16)
            $0.textColor = .init(hexCode: "3D1C1C")
        }
        
        _ = UIStackView(arrangedSubviews: [kakaoImageView, kakaoLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 12
            self.kakaoLoginBoxView.addSubview($0)
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
    }
}
