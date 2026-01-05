//
//  Date+Extension.swift
// ALNASR
//
//  Created by developer on 10/02/22.
//
import SwiftUI

extension Date {
    private func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func yearsCount(from date: Date) -> Int {
        let fromDate = date.startOfDay()
        let toDate   = self.startOfDay()
        return Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year ?? 0
    }

    func monthsCount(from date: Date) -> Int {
        let fromDate = date.startOfDay()
        let toDate   = self.startOfDay()
        return Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month ?? 0
    }

    func weeksCount(from date: Date) -> Int {
        let fromDate = date.startOfDay()
        let toDate   = self.startOfDay()
        return Calendar.current.dateComponents([.weekOfYear], from: fromDate, to: toDate).weekOfYear ?? 0
    }

    func daysCount(from date: Date) -> Int {
        let fromDate = date.startOfDay()
        let toDate   = self.startOfDay()
        return Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
    }

    func hoursCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    func minutesCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func secondsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    func pluralize(_ value: Int, singular: String, plural: String? = nil) -> String {
        let pluralForm = plural ?? singular + "s"
        
        // Localize the singular, plural, and 'ago' part
        let localizedSingular = singular.localizedString()
        let localizedPlural = plural?.localizedString() ?? (singular + "s").localizedString()
        let agoText = "ago".localizedString()
        
        return value == 1
            ? "1 \(localizedSingular) \(agoText)"
            : "\(value) \(localizedPlural) \(agoText)"
    }

    func timeAgo(from date: Date) -> String {
        if yearsCount(from: date) > 0 {
            return pluralize(yearsCount(from: date), singular: "year")
        }
        if monthsCount(from: date) > 0 {
            return pluralize(monthsCount(from: date), singular: "month")
        }
        if weeksCount(from: date) > 0 {
            return pluralize(weeksCount(from: date), singular: "week")
        }
        if daysCount(from: date) > 0 {
            return pluralize(daysCount(from: date), singular: "day")
        }
        if hoursCount(from: date) > 0 {
            return pluralize(hoursCount(from: date), singular: "hour")
        }
        if minutesCount(from: date) > 0 {
            return pluralize(minutesCount(from: date), singular: "minute")
        }
        if secondsCount(from: date) > 0 {
            return pluralize(secondsCount(from: date), singular: "second")
        }
        return "just_now".localizedString()
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
