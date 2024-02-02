//
//  ViewRouter.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/15/24.
//

import UIKit

final class ViewRouter {
    static func presentToNextViewController(from source: BaseViewController, to next: BaseViewController, sceneDelegate: SceneDelegate, modalPresentationStyle: UIModalPresentationStyle = .overFullScreen, animated: Bool = true) {
        next.sceneDelegate = sceneDelegate
        next.modalPresentationStyle = modalPresentationStyle
        source.present(next, animated: animated, completion: nil)
    }
    
    static func presentToNextViewController(from source: BaseViewController, to next: BaseViewController, modalPresentationStyle: UIModalPresentationStyle = .overFullScreen, animated: Bool = true) {
        next.modalPresentationStyle = modalPresentationStyle
        source.present(next, animated: animated, completion: nil)
    }
    
    static func pushToNextViewContoller(from source: BaseViewController, to next: BaseViewController, sceneDelegate: SceneDelegate, animated: Bool = true) {
        next.sceneDelegate = sceneDelegate
        source.navigationController?.pushViewController(next, animated: animated)
    }
    
    static func pushToNextViewContoller(from source: BaseViewController, to next: BaseViewController, animated: Bool = true) {
        source.navigationController?.pushViewController(next, animated: animated)
    }
}

