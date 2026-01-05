//
//  Date+Extension.swift
// ALNASR
//
//  Created by developer on 10/02/22.
//
import SwiftUI

extension Date {
    
    func yearsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
     }
     // Returns the number of months
     func monthsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
     }
     // Returns the number of weeks
     func weeksCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
     }
     // Returns the number of days
     func daysCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
     }
     // Returns the number of hours
     func hoursCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
     }
     // Returns the number of minutes
    func minutesCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
     }
     // Returns the number of seconds
     func secondsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
     }

    func timeAgo(from date: Date) -> String {
        if yearsCount(from: date)   > 0 { return "\(yearsCount(from: date)) years ago"   }
        if monthsCount(from: date)  > 0 { return "\(monthsCount(from: date)) months ago"  }
        if weeksCount(from: date)   > 0 { return "\(weeksCount(from: date)) weeks ago"   }
        if daysCount(from: date)    > 0 { return "\(daysCount(from: date)) days ago"    }
        if hoursCount(from: date)   > 0 { return "\(hoursCount(from: date)) hours ago"   }
        if minutesCount(from: date) > 0 { return "\(minutesCount(from: date)) minutes ago" }
        if secondsCount(from: date) > 0 { return "\(secondsCount(from: date)) seconds ago" }
        return ""
    }
    
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    
    func formattedDateString(format: String? = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func startDateText() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM yyyy"
        return formatter1.string(from: self)
    }
    
    func endDateText() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM yyyy"
        return formatter1.string(from: self)
    }
    
    var repoDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let string = dateFormatter.string(from: self)
        return string
    }
    
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
        
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
