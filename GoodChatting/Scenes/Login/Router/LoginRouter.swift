//
//  LoginRouter.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import UIKit

final class LoginRouter {
    
    func presentToNextViewController(with source: UIViewController, reactor: LoginReactor, sceneDelegate: SceneDelegate) {
        let nextViewController = LoginViewController()
        nextViewController.reactor = reactor
        nextViewController.sceneDelegate = sceneDelegate
        nextViewController.modalPresentationStyle = .overFullScreen
        source.present(nextViewController, animated: true, completion: nil)
    }
    
    func pushToNextViewContoller(with source: UIViewController, reactor: LoginReactor) {
        let nextViewController = LoginViewController()
        nextViewController.reactor = reactor
        source.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func presentToNextViewController(with source: UIViewController, reactor: LoginReactor) {
        let nextViewController = LoginViewController()
        nextViewController.reactor = reactor
        nextViewController.modalPresentationStyle = .overFullScreen
        source.present(nextViewController, animated: true, completion: nil)
    }
}

