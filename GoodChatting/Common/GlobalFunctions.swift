//
//  GlobalFunctions.swift
//  GoodChatting
//
//  Created by 김광록 on 1/15/24.
//

import UIKit

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
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        toastLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        toastLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        toastLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true

        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
