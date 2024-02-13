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

    /// kkr's Log
    static func kkr(_ any: Any, filename: String = #file, funcName: String = #function) {
        #if DEBUG
        print("[🐳kkr][\(sourceFileName(filePath: filename))] \(funcName) -> \(any)\n")
        #endif
    }
    
    /// Yunoh's Log
    static func cyo(_ any: Any, filename: String = #file, funcName: String = #function, line: Int = #line) {
        #if DEBUG
        print("[😡cyo][line: \(line)][\(sourceFileName(filePath: filename))] \(funcName) -> \(any)")
        #endif
    }
 
    static func sourceFileName(filePath: String) -> String {
       let components = filePath.components(separatedBy: "/")
       return components.isEmpty ? "" : components.last!
    }
}
