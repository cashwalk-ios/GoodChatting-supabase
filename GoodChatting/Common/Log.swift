//
//  Log.swift
//  GoodChatting
//
//  Created by Rocky on 1/12/24.
//

import Foundation

struct Log {

    /// Rocky's Log
    static func rk(_ any: Any, filename: String = #file, funcName: String = #function) {
        #if DEBUG
        print("[🐬RK][\(sourceFileName(filePath: filename))] \(funcName) -> \(any)\n")
        #endif
    }
 
    static func sourceFileName(filePath: String) -> String {
       let components = filePath.components(separatedBy: "/")
       return components.isEmpty ? "" : components.last!
    }
}
