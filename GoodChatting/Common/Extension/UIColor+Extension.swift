//
//  UIColor + Extension.swift
//  GoodChatting
//
//  Created by Rocky on 1/5/24.
//

import UIKit

enum GCColor {
    
    /// #000000
    case black(_ alpha: Double = 1.0)
    /// #FFFFFF
    case white(_ alpha: CGFloat = 1.0)
    /// #F4F4F4
    case mainGray(_ alpha: CGFloat = 1.0)
    /// #F8FAF9
    case secondGray(_ alpha: CGFloat = 1.0)
    
}

extension UIColor {
    
    static func designColor(color: GCColor) -> UIColor {
        switch color {
        case .black(let alpha):
            return UIColor(hexCode: "000000", alpha: alpha)
        case .white(let alpha):
            return UIColor(hexCode: "ffffff", alpha: alpha)
        case .mainGray(let alpha):
            return UIColor(hexCode: "f4f4f4", alpha: alpha)
        case .secondGray(let alpha):
            return UIColor(hexCode: "f8faf9", alpha: alpha)
        }
    }
    
    /// 헥사 컬러 변환
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    
    
}
