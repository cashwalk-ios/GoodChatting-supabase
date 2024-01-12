//
//  UIFont+Extension.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import UIKit

enum FontType {
    case regular
    case medium
    case bold
    case light
    case semiBold
}

extension UIFont {
    class func appleSDGothicNeo(_ type: FontType, size: CGFloat) -> UIFont {
        switch type {
        case .regular:
            return UIFont(name: "AppleSDGothicNeo-Regular", size: size) ?? .systemFont(ofSize: size)
        case .medium:
            return UIFont(name: "AppleSDGothicNeo-medium", size: size) ?? .systemFont(ofSize: size)
        case .bold:
            return UIFont(name: "AppleSDGothicNeo-Bold", size: size) ?? .systemFont(ofSize: size)
        case .light:
            return UIFont(name: "AppleSDGothicNeo-Light", size: size) ?? .systemFont(ofSize: size)
        case .semiBold:
            return UIFont(name: "AppleSDGothicNeo-SemiBold", size: size) ?? .systemFont(ofSize: size)
        }
    }
}
