import Foundation
import UIKit.UITextField

protocol ValidatorConvertible {
    func validated(_ value: String?) throws -> String?
    func validated(_ value: NSNumber) throws -> NSNumber

}

extension ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        return ""
    }
    func validated(_ value: NSNumber) throws -> NSNumber {
        return NSNumber(value: NSNotFound)
    }

}

enum ValidatorType {
    case phone(field: String? = nil)
    case email
    case password
    case username
    case projectIdentifier
    case requiredNumber(field: String)
    case requiredField(field: String)
    case matchingField(field: String, with: String)
    case compareDates(format: String, field: String, date1: String)
    case equalCompareDates(format: String, field: String, date1: String)
    case age
    case country
    case otp
    case zip
    case minimumNumber(value: NSNumber, with: NSNumber, field: String)
    case url(field: String? = nil)

}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email: return EmailValidator()
        case .password: return PasswordValidator()
        case .username: return UserNameValidator()
        case .projectIdentifier: return ProjectIdentifierValidator()
        case .requiredField(let fieldName): return RequiredFieldValidator(fieldName)
        case .age: return AgeValidator()
        case .phone(let fieldName): return PhoneValidator(fieldName)
        case .matchingField(let fieldName, let withText): return MatchingFieldValidator(fieldName, checkwith: withText)
        case .country: return CountryValidator()
        case .otp: return OTPValidator()
        case .compareDates(let format, let fieldName, let date1): return DateComparisonValidator(format, field: fieldName, checkwith: date1)
        case .requiredNumber(let field): return RequiredFieldNumberValidator(field)
        case .zip: return ZipValidator()
        case .equalCompareDates(let format, let fieldName, let date1):  return DateEqualComparisonValidator(format, field: fieldName, checkwith: date1)
        case .minimumNumber(let value, let with, let field): return MinimumNumberValidator(value, checkwith: with, fieldName: field)
        case .url(let fieldName): return URLAddressValidator(fieldName)
        }
    }
}

//"J3-123A" i.e
struct ProjectIdentifierValidator: ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("Project Identifier is required", type: .validation) }
        do {
            if try NSRegularExpression(pattern: "^[A-Z]{1}[0-9]{1}[-]{1}[0-9]{3}[A-Z]$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw SystemError("Invalid Project Identifier Format", type: .validation)
            }
        } catch {
            throw SystemError("Invalid Project Identifier Format", type: .validation)
        }
        return value
    }
}


class AgeValidator: ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("Age is required", type: .validation) }
        guard value.count > 0 else {throw SystemError("Age is required", type: .validation)}
        guard let age = Int(value) else {throw SystemError("Age must be a number!", type: .validation)}
        guard value.count < 3 else {throw SystemError("Invalid age number!", type: .validation)}
        guard age >= 18 else {throw SystemError("You have to be over 18 years old to user our app :)", type: .validation)}
        return value
    }
}

struct RequiredFieldValidator: ValidatorConvertible {
    private let fieldName: String
    
    init(_ field: String) {
        fieldName = field
    }
    
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        guard !value.isEmpty, !value.isEmptyOrWhitespace() else {
            throw SystemError("Required Field %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}

struct RequiredFieldNumberValidator: ValidatorConvertible {

    private let fieldName: String
    
    init(_ field: String) {
        fieldName = field
    }
    
    func validated(_ value: NSNumber) throws -> NSNumber {
        let error =  SystemError("Required Field %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        if value == NSNumber(value: NSNotFound) {
            throw error
        }
        if value.doubleValue <= 0 {
            throw error
        } else if value.intValue <= 0  {
            throw error
        }
        
        return value
    }
}

struct DateEqualComparisonValidator: ValidatorConvertible {
    private let fieldName: String
    private let checkwith: String
    private let format: String

    init(_ format: String, field: String, checkwith: String) {
        self.fieldName = field
        self.checkwith = checkwith
        self.format = format
    }
    
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let firstDate = formatter.date(from: checkwith)
        let secondDate = formatter.date(from: value)
        
        if (firstDate?.compare(secondDate!) == .orderedDescending) || (firstDate?.compare(secondDate!) == .orderedSame) {
            throw SystemError("%@ MISMATCH".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        if (Date().compare(firstDate!) == .orderedDescending) || (Date().compare(secondDate!) == .orderedDescending) {
            throw SystemError("%@ MISMATCH".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}


struct MinimumNumberValidator: ValidatorConvertible {
    private let count: NSNumber
    private let checkwith: NSNumber
    private let fieldName: String

    init(_ count: NSNumber, checkwith: NSNumber, fieldName: String) {
        self.count = count
        self.checkwith = checkwith
        self.fieldName = fieldName
    }
    
    func validated(_ value: NSNumber) throws -> NSNumber {
        
        if (count.intValue < checkwith.intValue) {//|| (firstDate?.compare(secondDate!) == .orderedSame) {
            throw SystemError(fieldName + " should be less than " + checkwith.stringValue, type: .validation)
        }
        return value
    }
}

struct MaximumNumberValidator: ValidatorConvertible {
    private let count: NSNumber
    private let checkwith: NSNumber
    private let fieldName: String
    
    init(_ count: NSNumber, checkwith: NSNumber, fieldName: String) {
        self.count = count
        self.checkwith = checkwith
        self.fieldName = fieldName
    }
    
    func validated(_ value: NSNumber) throws -> NSNumber {
        
        if (count.intValue < checkwith.intValue) {
            throw SystemError(fieldName + " should be greater than " + checkwith.stringValue, type: .validation)
        }
        return value
    }
}

struct DateComparisonValidator: ValidatorConvertible {
    private let fieldName: String
    private let checkwith: String
    private let format: String
    
    init(_ format: String, field: String, checkwith: String) {
        self.fieldName = field
        self.checkwith = checkwith
        self.format = format
    }
    
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let firstDate = formatter.date(from: checkwith)
        let secondDate = formatter.date(from: value)
        
        if (firstDate?.compare(secondDate!) == .orderedDescending) {
            throw SystemError("%@ MISMATCH".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}

struct MatchingFieldValidator: ValidatorConvertible {
    private let fieldName: String
    private let checkwith: String
    
    init(_ field: String, checkwith: String) {
        fieldName = field
        self.checkwith = checkwith
    }
    
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        guard !value.isEmpty, value == self.checkwith else {
            throw SystemError("%@ MISMATCH".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}

struct UserNameValidator: ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("Username is required", type: .validation) }
        guard value.count >= 3 else {
            throw SystemError("Username must contain more than three characters", type: .validation)
        }
        guard value.count < 18 else {
            throw SystemError("Username shoudn't conain more than 18 characters", type: .validation)
        }
        
        do {
            if try NSRegularExpression(pattern: "^[a-z]{1,18}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw SystemError("Invalid username, username should not contain whitespaces, numbers or special characters", type: .validation)
            }
        } catch {
            throw SystemError("Invalid username, username should not contain whitespaces,  or special characters", type: .validation)
        }
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: ["Password"]), type: .validation) }
        guard value != "" else {throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: ["Password"]), type: .validation) }
        guard value.count >= 6 else { throw SystemError("Password must have at least 6 characters".localizedString(), type: .validation) }
        return value
    }
}

struct URLAddressValidator: ValidatorConvertible {
    private let fieldName: String
    
    init(_ field: String? = nil) {
        fieldName = field ?? "URL_ADDRESS".localizedString()
    }
    
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        do {
            if let url = URL(string: value), UIApplication.shared.canOpenURL(url) {
                // check if your application can open the NSURL instance
            } else {
                throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
            }
        } catch {
            throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        let fieldName = "Email Address".localizedString()
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation)}
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw SystemError("Invalid %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
            }
        } catch {
            throw SystemError("Invalid %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}

struct CountryValidator: ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        let fieldName = "COUNTRY".localizedString()
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        do {
            if value.isEmpty || value == "0" {
                throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
            }
        } catch {
            throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}


struct PhoneValidator: ValidatorConvertible {
    private let fieldName: String
    
    init(_ field: String? = nil) {
        fieldName = field ?? "PHONE_NUMBER".localizedString()
    }
    
    func validated(_ value: String?) throws -> String? {
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: value, options: [], range: NSMakeRange(0, value.count))
            if let res = matches.first {
                if !(res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == value.count) {
                    throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
                }
            } else {
                throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
            }
        } catch {
            throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}

class ZipValidator: ValidatorConvertible {
    func validated(_ value: NSNumber) throws -> NSNumber {
        let fieldName = "POSTAL_CODE".localizedString()
        do {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: value.stringValue)
            if !(allowedCharacters.isSuperset(of: characterSet)) || value.stringValue.count < 1 {
                throw SystemError("REQUIRED_FIELD %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
            }
        } catch {
            throw SystemError("REQUIRED_FIELD %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}

struct OTPValidator: ValidatorConvertible {
    func validated(_ value: String?) throws -> String? {
        let fieldName = "OTP_CODE".localizedString()
        guard let value = value else { throw SystemError("%@ IS_REQUIRED".localizedStringInFormat(arguments: [fieldName]), type: .validation) }
        do {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: value)
            if !(allowedCharacters.isSuperset(of: characterSet)) || value.count != 4 {
                throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
            }
        } catch {
            throw SystemError("INVALID %@".localizedStringInFormat(arguments: [fieldName]), type: .validation)
        }
        return value
    }
}



extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text) ?? ""
    }
}

extension UITextView {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text) ?? ""
    }
}

extension Double {
    func validatedText(validationType: ValidatorType) throws -> Double {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(NSNumber(value: self)).doubleValue
    }
}

extension Int {
    func validatedText(validationType: ValidatorType) throws -> Int {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(NSNumber(value: self)).intValue
    }
}

extension String {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self) ?? ""
    }
    
    func isEmptyOrWhitespace() -> Bool {
        if (self.isEmpty) {
            return true
        }
        return (self.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")
    }
}

extension String {
    func validateMobileNumber() -> String? {
        var mobileNo = self
        mobileNo = mobileNo.replacingOccurrences(of: "-", with: "")
        if !(mobileNo == "") && (mobileNo.count == 10) {
            return nil
        } else if (mobileNo == "") {
            return "Enter mobile number"
        } else {
            return "Enter a valid mobile number"
        }
    }
    
    func mobileNoFormatterOnKeyPress() -> String {
        var replacedText = self
        replacedText = replacedText.replacingOccurrences(of: "-", with: "")
        if replacedText.count > 3 {
            replacedText = (replacedText as NSString).replacingCharacters(in: NSRange(location: 3, length: 0), with: "-")
        }
        if replacedText.count > 7 {
            replacedText = (replacedText as NSString).replacingCharacters(in: NSRange(location: 7, length: 0), with: "-")
        }
        return replacedText
    }
    
    func isValidMobileNumber() -> Bool {
        var mobileNo = self
        mobileNo = mobileNo.replacingOccurrences(of: "-", with: "")
        if !(mobileNo.isEmpty) && (mobileNo.count == 10) {
            return true
        }
        return false
    }
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func validateNumeric() -> Bool{
        let scanner = Scanner(string: self.trimmingCharacters(in: NSCharacterSet.whitespaces))
        return scanner.scanInt(nil) && scanner.isAtEnd
    }
    
}
