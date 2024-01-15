//
//  ViewRouter.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/15/24.
//

import UIKit

final class ViewRouter {
    static func presentToNextViewController(from source: BaseViewController, to next: BaseViewController, sceneDelegate: SceneDelegate) {
        next.sceneDelegate = sceneDelegate
        next.modalPresentationStyle = .overFullScreen
        source.present(next, animated: true, completion: nil)
    }
    
    static func pushToNextViewContoller(from source: BaseViewController, to next: BaseViewController) {
        source.navigationController?.pushViewController(next, animated: true)
    }
    
    static func presentToNextViewController(from source: BaseViewController, to next: BaseViewController) {
        next.modalPresentationStyle = .overFullScreen
        source.present(next, animated: true, completion: nil)
    }
}

