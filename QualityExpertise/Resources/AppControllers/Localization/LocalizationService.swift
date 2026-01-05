//
//  LocalizationService.swift
// QualityExpertise
//
//  Created by Developer on 21/10/21.
//

import SwiftUI
//https://stackoverflow.com/a/63951611

class LocalizationService {

    static let shared = LocalizationService()

    private init() {}
    
    var language: Language {
        get {
            // Get the actual app/phone language (respects system preferences)
            let phoneLangCode = Bundle.main.preferredLocalizations.first ?? "en"
            
            // If phone language is English, allow user override
            if phoneLangCode == "en" {
                if let savedLanguage = UserDefaults.standard.string(forKey: "language"),
                   let lang = Language(rawValue: savedLanguage) {
                    return lang
                } else {
                    return .english
                }
            } else {
                // Otherwise follow the phone language
                return Language(rawValue: phoneLangCode) ?? .english
            }
        }
        set {
            // Only save if phone language is English
            let phoneLangCode = Bundle.main.preferredLocalizations.first ?? "en"
            if phoneLangCode == "en" {
                UserDefaults.standard.setValue(newValue.rawValue, forKey: "language")
            } else {
                print("Ignoring manual language change — following phone language: \(phoneLangCode)")
            }
        }
    }


}

extension View {
    func localize() -> some View {
        self
            .environment(\.locale, .init(identifier: LocalizationService.shared.language.rawValue))
            .environment(\.layoutDirection, LocalizationService.shared.language.isRTLLanguage ? .rightToLeft : .leftToRight)
    }
}


extension String {
    func localizedString() -> String {
        LocalizedStringKey(self).stringValue()
    }
    
    func localizedStringInFormat(arguments: [CVarArg]) -> String {
        let language = LocalizationService.shared.language
        let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = String(format: NSLocalizedString(self, bundle: bundle, comment: ""), arguments: arguments)
        return localizedString
    }
}

extension LocalizedStringKey {
    var stringKey: String {
        let description = "\(self)"

        let components = description.components(separatedBy: "key: \"")
            .map { $0.components(separatedBy: "\",") }

        return components[1][0]
    }
}

extension String {
    static func localizedString(for key: String,
                                locale: Locale = .current) -> String {
        
        let language = LocalizationService.shared.language
        let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
}

extension LocalizedStringKey {
    func stringValue(locale: Locale = .current) -> String {
        return .localizedString(for: self.stringKey, locale: locale)
    }
}
