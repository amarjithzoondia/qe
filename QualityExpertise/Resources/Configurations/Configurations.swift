//
//  Configurations.swift
// QualityExpertise
//
//  Created by Vivek M on 01/03/21.
//

import Foundation

struct Configurations {
    
    static func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: Constants.BACKWARD_SLASHES, with: Constants.EMPTY_STRING)
    }
    
    static func infoFor(dictionaryKey: String, stringKey: String) -> String? {
        let dictionary = Bundle.main.infoDictionary?[dictionaryKey] as? [String: Any]
        let string = dictionary?[stringKey] as? String
        return string?.replacingOccurrences(of: Constants.BACKWARD_SLASHES, with: Constants.EMPTY_STRING)
    }
    
    static func configurationFor(dictionaryKey: String, stringKey: String) -> String? {
        let dictionary = (Bundle.main.infoDictionary?[Constants.CONFIGURATIONS] as? [String: Any])?[dictionaryKey] as? [String: Any]
        let string = dictionary?[stringKey] as? String
        return string?.replacingOccurrences(of: Constants.BACKWARD_SLASHES, with: Constants.EMPTY_STRING)
    }
    
    struct API {
        static let SERVICE_ROOT = configurationFor(dictionaryKey: "API", stringKey: "API_SERVICE_ROOT")!
        static let SERVICE_FOLDER = configurationFor(dictionaryKey: "API", stringKey: "API_SERVICE_FOLDER")!
        static let SECRET_KEY = configurationFor(dictionaryKey: "API", stringKey: "API_SECRET_KEY")!
    }
    
    struct GOOGLE {
        static let GOOGLE_API_KEY = configurationFor(dictionaryKey: "GOOGLE", stringKey: "GOOGLE_API_KEY")!
    }
    
    struct AD {
        static let AD_UNIT_ID = configurationFor(dictionaryKey: "AD", stringKey: "AD_UNIT_ID")
        static let IS_TEST_AD = configurationFor(dictionaryKey: "AD", stringKey: "IS_TEST_AD")
    }
    
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var versionString: String? {
        let appVersion = Bundle.main.infoDictionary?[Constants.CF_BUNDLE_SHORT_VERSION_STRING] as! String
        let appVersionString = "v.\(appVersion) "
        
        let configDict = (Bundle.main.infoDictionary?[Constants.CONFIGURATIONS] as! [String: Any])
        let configName = configDict["NAME"] as! String
        let showConfigInfo = Int((configDict["SHOW_CONFIG_INFO"] as! String)) != 0
        
        let info = appVersionString + (showConfigInfo ? "(\(configName))" : "")
        let currentYear = Calendar.current.component(.year, from: Date())
        return "\(info)\n© \(currentYear) QualityExpertise. All Rights Reserved."
    }
}
