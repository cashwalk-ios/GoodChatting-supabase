//
//  GlobalFunctions.swift
//  GoodChatting
//
//  Created by 김광록 on 1/15/24.
//

import UIKit
import SnapKit
import Then
import CryptoKit

class GlobalFunctions {
    public static func makeAlert(
        title: String? = nil,
        message: String? = nil,
        firstActionMsg: String,
        firstActionHandler: (() -> Void)? = nil,
        cancelActionMsg: String? = nil,
        cancelActionHandler: (() -> Void)? = nil
    ) -> UIViewController {
        let alertViewController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let firstAction = UIAlertAction(title: firstActionMsg, style: .default) { _ in
            firstActionHandler?()
        }
        alertViewController.addAction(firstAction)
        
        if let secondaryActionMsg = cancelActionMsg {
            let secondaryAction = UIAlertAction(title: secondaryActionMsg, style: .cancel) { _ in
                cancelActionHandler?()
            }
            alertViewController.addAction(secondaryAction)
        }
        
        return alertViewController
    }
    
    public static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            let toastLabel = UILabel().then {
                $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                $0.textColor = UIColor.white
                $0.textAlignment = .center
                $0.font = .appleSDGothicNeo(.regular, size: 16)
                $0.text = message
                $0.alpha = 1.0
                $0.clipsToBounds = true
                self.view.addSubview($0)
            }
            
            toastLabel.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(60)
            }
            
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

}
