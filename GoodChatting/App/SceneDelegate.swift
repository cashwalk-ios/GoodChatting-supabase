//
//  SceneDelegate.swift
//  GoodChatting
//
//  Created by Rocky on 1/4/24.
//

import UIKit
import KakaoSDKAuth
import ReactorKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let splashVC = SplashViewController()
        splashVC.sceneDelegate = self
        
        let navController = UINavigationController(rootViewController: splashVC)
        window.rootViewController = navController
        self.window = window
        self.window?.makeKeyAndVisible()
        
        // 앱이 꺼져있는 경우
        if let urlContext = connectionOptions.urlContexts.first {
            handleAppSchemes(connectionOptions.urlContexts)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        handleKakaoLoginURL(URLContexts)
        handleAppSchemes(URLContexts)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

extension SceneDelegate {
    
    func navigateToHome(with userCYO: UserCYO?, joinCode: String? = nil) {
        let homeVC = HomeViewController()
        homeVC.reactor = HomeReactor(userCYO: userCYO)
        homeVC.sceneDelegate = self
        window?.rootViewController = UINavigationController(rootViewController: homeVC)
        window?.makeKeyAndVisible()
        
        if let code = joinCode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                homeVC.reactor?.action.onNext(.chattingAddAction(.joinRoom(code)))
            }
        }
    }
    
    func navigateToSplash() {
        let splashVC = SplashViewController()
        splashVC.sceneDelegate = self
        window?.rootViewController = UINavigationController(rootViewController: splashVC)
        window?.makeKeyAndVisible()
    }
    
    // FIXME: 추후 Supabase에서 카카오 로그인을 Swift SDK로 지원하면 그때 추가
//    fileprivate func handleKakaoLoginURL(_ URLContexts: Set<UIOpenURLContext>) {
//        if let url = URLContexts.first?.url {
//            if (AuthApi.isKakaoTalkLoginUrl(url)) {
//                _ = AuthController.handleOpenUrl(url: url)
//            }
//        }
//    }
    
    fileprivate func handleAppSchemes(_ URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            let url = urlContext.url
            Log.kkr("url: \(url)")
            
            if url.scheme == "goodchattingapp" {
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      let queryItems = components.queryItems else { return }
                
                let code = queryItems.first(where: { $0.name == "joinCode" })?.value
                navigateToHome(with: UserCYO(id: UserSettings.userId ?? "", email: nil), joinCode: code)
            }
        }
    }
}
