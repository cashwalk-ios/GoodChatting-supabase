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
            let isLoggedIn = UserSettings.isLoggedIn
            Log.kkr("로그인 여부: \(isLoggedIn)")
            
            if isLoggedIn {
                self.sceneDelegate?.navigateToHome(from: self, animated: false)
            } else {
                self.navigateToLogin()
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

