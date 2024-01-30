//
//  BlackView.swift
//  GoodChatting
//
//  Created by Rocky on 1/30/24.
//

import UIKit

final class BlackView: UIView {

    init(alphaValue: CGFloat) {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(alphaValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BlackView {
    
    func show(onView view: UIView, withDuration: Double = 0.3) {
        self.alpha = 0
        self.frame = view.bounds
        view.addSubview(self)
        UIView.animate(withDuration: withDuration) {
            self.alpha = 1
        }
    }
    
    func hide() {
        self.removeFromSuperview()
    }
    
}
