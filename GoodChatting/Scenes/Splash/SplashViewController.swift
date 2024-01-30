//
//  SplashViewController.swift
//  GoodChatting
//
//  Created by 김광록 on 1/12/24.
//

import UIKit
import SnapKit
import Then

final class SplashViewController: BaseViewController {
    
    // MARK: - Properties
    
    var userInfo: UserInfo?

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        setupView()
        setupProperties()
        checkLoginStatus()
    }
    
    // MARK: - Functions
    
    private func setupProperties() {
        self.view.backgroundColor = .designColor(color: .secondGray())
    }
    
    private func setupView() {
        let logoView = UIImageView().then {
            $0.image = UIImage(named: "launch-icon")
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-70)
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            logoView.transform = CGAffineTransform(translationX: 0, y: -20)
        }, completion: nil)
    }
    
    private func checkLoginStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            guard let self else { return }
            
            // 로그인 여부 검사
            Task {
                self.userInfo = try await AuthManager.shared.getCurrentSession()
                if let userInfo = self.userInfo {
                    Log.kkr("자동 로그인 - uid: \(userInfo.uid), email: \(userInfo.email ?? "이메일 없음")")
                    self.sceneDelegate?.navigateToHome(from: self, animated: false)
                } else {
                    Log.kkr("세션 만료 - LoginViewController ㄱㄱ")
                    self.navigateToLogin()
                }
            }
        })
    }
    
    private func navigateToLogin() {
        let vc = LoginViewController()
        vc.reactor = LoginReactor()
        
        if let sceneDelegate = self.sceneDelegate {
            ViewRouter.presentToNextViewController(from: self, to: vc, sceneDelegate: sceneDelegate)
        }
    }

}

