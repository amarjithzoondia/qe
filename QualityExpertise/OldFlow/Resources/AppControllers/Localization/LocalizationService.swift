//
//  LocalizationService.swift
// ALNASR
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
            guard let languageString = UserDefaults.standard.string(forKey: "language") ?? Locale.current.languageCode else {
                return .english
            }
            return Language(rawValue: languageString) ?? .english
        } set {
            if newValue != language {
                UserDefaults.standard.setValue(newValue.rawValue, forKey: "language")
            }
        }
    }
}

extension View {
    func localize() -> some View {
        self
            .environment(\.locale, .init(identifier: LocalizationService.shared.language.rawValue))
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
        
        let language = LocalizationService.shared.language //locale.languageCode
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
