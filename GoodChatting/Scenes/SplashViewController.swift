//
//  SplashViewController.swift
//  GoodChatting
//
//  Created by 김광록 on 1/12/24.
//

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Properties

    weak var sceneDelegate: SceneDelegate?

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        checkLoginStatus()
    }
    
    // MARK: - Functions
    
    private func checkLoginStatus() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if isLoggedIn {
            sceneDelegate?.navigateToHome()
        } else {
            navigateToLogin()
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: false)
    }

}
