//
//  HomeRouter.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import UIKit

final class HomeRouter {
    
    func pushToNextViewContoller(with source: UIViewController, reactor: HomeReactor) {
        let nextViewController = HomeViewController()
        nextViewController.reactor = reactor
        source.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func presentToNextViewController(with source: UIViewController, reactor: HomeReactor) {
        let nextViewController = HomeViewController()
        nextViewController.reactor = reactor
        nextViewController.modalPresentationStyle = .overFullScreen
        source.present(nextViewController, animated: true, completion: nil)
    }
}
