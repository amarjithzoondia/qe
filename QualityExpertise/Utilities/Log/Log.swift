//
//  Log.swift
// ALNASR
//
//  Created by Vivek M on 16/07/21.
//

import Foundation

struct Log {
    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if Configurations.isDebug {
            Swift.print(items, separator: separator, terminator: terminator)
        }
    }
    
    static func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if Configurations.isDebug {
            Swift.debugPrint(items, separator: separator, terminator: terminator)
        }
    }
}
