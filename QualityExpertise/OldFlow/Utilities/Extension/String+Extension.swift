//
//  String+Extension.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import Foundation

extension String {
    func enterPlaceholder(isCapital: Bool = true) -> String {
        if isCapital {
            return "ENTER".localizedString() + Constants.SPACE + self
        } else {
            return "Enter".localizedString() + Constants.SPACE + self
        }
    }
}

extension String {
    func fieldLimit(limit: Int) -> String {
        if count > limit {
                       let newString = String(self.prefix(limit))
            return newString
        }
        return self
    }
}

extension String {
    var url: URL? {
        URL(string: self)
    }
    
    var toInt: Int? {
        Int(self)
    }
}

extension String {
    func convertDateFormater(dateFormat: String, inputFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        guard let date = dateFormatter.date(from: self) else { return "" }
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
        
    }
    
    func toDateFormat(_ format: String? = nil) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.REPO_DATE
        if let date = formatter.date(from: self) {
            if let format = format {
                formatter.dateFormat = format
            } else {
                formatter.dateStyle = .medium
            }
            return formatter.string(from: date)
        }
        return nil
    }
    
    func convertTImeFormat() -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "HH:mm:ss"
         let dateFromStr = dateFormatter.date(from: self)!
         dateFormatter.dateFormat = "h:mm a"
         let timeFromDate = dateFormatter.string(from: dateFromStr)
         return timeFromDate
     }
    
    func repoDate(inputFormat: String = Constants.DateFormat.REPO_DATE) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        return dateFormatter.date(from: self)
    }
    
    func repoTimeDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.date(from: self)
    }
}

extension String {
    var selectPlaceholder: String {
        "Pick".localizedString() + Constants.SPACE + self
    }
}

extension String {
    func modifyTogroupCode() -> String {
        if !(isEmpty) && (count > Constants.Number.Limit.GROUPCODEPARTONE) {
            let new = dropLast()
            return String(new)
        }

        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = components(separatedBy: cs).joined(separator: "")
        if self != filtered {
            let new = self.dropLast()
            return String(new)
        }

        return self
    }
}
