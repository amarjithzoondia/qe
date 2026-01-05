//
//  Int+Extension.swift
// ALNASR
//
//  Created by developer on 28/01/22.
//

import Foundation

extension Int {
    var string: String {
        "\(self)"
    }
}

extension Int {
    var secondsToTimeFormatted: String {
        let seconds: Int = self % 60
        let minutes: Int = (self / 60) % 60
        let hours: Int = self / 3600
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
     }
}
