//
//  SplashViewController.swift
//  GoodChatting
//
//  Created by 김광록 on 1/12/24.
//

import UIKit
import SnapKit
import Then
import Supabase

final class SplashViewController: BaseViewController {
    
    // MARK: - Properties
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            
            Task {
                do {
                    if let currentSession = try await AuthManager.shared.getCurrentSession() {
                        // 자동 로그인 로직
                        let userCYO = try await self.fetchUserCYO(for: currentSession.id)
                        UserSettings.userId = currentSession.id
                        self.sceneDelegate?.navigateToHome(with: userCYO.first)
                    } else {
                        // 세션 만료 처리
                        self.navigateToLogin()
                    }
                } catch {
                    Log.kkr("Error: \(error)")
                    self.navigateToLogin()
                }
            }
        }
    }
    
    private func fetchUserCYO(for userId: String) async throws -> [UserCYO] {
        let response = try await AuthManager.shared.client.database
            .from("userCYO")
            .select("*")
            .eq("id", value: userId)
            .execute()
        guard let jsonString = String(data: response.data, encoding: .utf8) else { throw NSError() }
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([UserCYO].self, from: jsonData)
    }
    
    private func navigateToLogin() {
        let vc = LoginViewController()
        vc.reactor = LoginReactor()
        
        if let sceneDelegate = self.sceneDelegate {
            ViewRouter.presentToNextViewController(from: self, to: vc, sceneDelegate: sceneDelegate)
        } else {
            Log.kkr("sceneDelegate is nil")
        }
    }
    
}

