//
//  SplashViewController.swift
//  GoodChatting
//
//  Created by 김광록 on 1/12/24.
//

import UIKit
import SnapKit
import Then

final class SplashViewController: UIViewController {

    // MARK: - Properties

    weak var sceneDelegate: SceneDelegate?

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
            let isLoggedIn = UserSettings.isLoggedIn
            print("로그인 여부: \(isLoggedIn)")
            
            if isLoggedIn {
                let reactor = HomeReactor()
                self?.sceneDelegate?.navigateToHome(reactor: reactor)
            } else {
                self?.navigateToLogin()
            }
        })
    }
    
    private func navigateToLogin() {
        let vc = LoginRouter()
        let reactor = LoginReactor()
        if let sceneDelegate = self.sceneDelegate {
            vc.presentToNextViewController(with: self, reactor: reactor, sceneDelegate: sceneDelegate)
        }
    }

}

