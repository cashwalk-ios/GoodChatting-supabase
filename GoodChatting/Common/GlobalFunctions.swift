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
        firstActionStyle: UIAlertAction.Style = .default,
        firstActionHandler: (() -> Void)? = nil,
        cancelActionMsg: String? = nil,
        cancelActionStyle: UIAlertAction.Style = .cancel,
        cancelActionHandler: (() -> Void)? = nil
    ) -> UIViewController {
        let alertViewController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let firstAction = UIAlertAction(title: firstActionMsg, style: firstActionStyle) { _ in
            firstActionHandler?()
        }
        alertViewController.addAction(firstAction)
        
        if let secondaryActionMsg = cancelActionMsg {
            let secondaryAction = UIAlertAction(title: secondaryActionMsg, style: cancelActionStyle) { _ in
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
    
    class func shake(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        let center: CGPoint = view.center
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5.0, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5.0, y: center.y))
        
        DispatchQueue.main.async {
            view.layer.add(animation, forKey: "position")
        }
    }
    
    class func showToast(message: String, duration: TimeInterval = 1.0) {
        DispatchQueue.main.async {
            let toastTag = 9999
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
            guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
            if window.viewWithTag(toastTag) != nil { return }
            
            let toastLabel = UILabel().then {
                $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                $0.textColor = UIColor.white
                $0.textAlignment = .center
                $0.font = .appleSDGothicNeo(.regular, size: 16)
                $0.text = message
                $0.alpha = 1.0
                $0.clipsToBounds = true
                window.addSubview($0)
            }
            
            toastLabel.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(60)
            }
            
            UIView.animate(
                withDuration: 0.3,
                delay: duration,
                options: .curveEaseOut,
                animations: {
                    toastLabel.alpha = 0.0
                },
                completion: { _ in
                    toastLabel.removeFromSuperview()
                })
        }
    }
    
    /// 고유한 랜덤 코드 생성
    ///
    /// '-' 하이픈을 제거하고 어미에 'g.sh/'를 붙여 생성
    class func GenerateUniqueRandomCode() -> String {
        let uniqueCode = UUID().uuidString
        let removeHyphen = uniqueCode.replacingOccurrences(of: "-", with: "")
        let addPrefix = "g.sh/" + removeHyphen
        return addPrefix
    }
    
    class func makeShareLink(joinCode: String) -> String {
        return "goodchatting://?joinCode=\(joinCode)"
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
