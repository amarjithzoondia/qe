//
//  DispatchQueue+Extension.swift
//  ALNASR
//
//  Created by Vivek M on 25/07/25.
//

import Foundation

extension DispatchQueue {
    static func safeAsyncMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}

