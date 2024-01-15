//
//  GlobalFunctions.swift
//  GoodChatting
//
//  Created by 김광록 on 1/15/24.
//

import UIKit
import SnapKit
import Then

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
}

extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel().then {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            $0.textColor = UIColor.white
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 12.0)
            $0.text = message
            $0.alpha = 1.0
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
            self.view.addSubview($0)
        }
        
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-100)
            make.width.equalTo(300)
            make.height.equalTo(35)
        }
        
        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
