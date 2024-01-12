//
//  UserSettings.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import Foundation

struct UserSettings {
    
    @UserDefault("isLoggedIn", defaultValue: false)
    static var isLoggedIn: Bool
    
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
