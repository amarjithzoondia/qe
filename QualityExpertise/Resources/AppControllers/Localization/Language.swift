//
//  Language.swift
// QualityExpertise
//
//  Created by Developer on 02/11/21.
//

//
//  Language.swift
//  QualityExpertise
//
//  Created by Developer on 02/11/21.
//

import Foundation

enum Language: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case english = "en"
    //    case arabic  = "ar"
//    case urdu    = "ur-Arab"
    //    case hindi   = "hi"
    
    var repoValue: String {
        switch self {
        case .english:
            return "1"
            //        case .arabic:
            //            return "2"
//        case .urdu:
//            return "3"
            //        case .hindi:
            //            return "4"
        }
    }
    
    var description: String {
        switch self {
        case .english:
            return "English"
            //        case .arabic:
            //            return "العربية"
//        case .urdu:
//            return "اردو"
            //        case .hindi:
            //            return "हिन्दी"
        }
    }
    
    var isRTLLanguage: Bool {
        switch self {
        case .english:
            false
            //        case .arabic:
            //            true
//        case .urdu:
//            true
            //        case .hindi:
            //            false
        }
    }
    
    //    var icon: String {
    //        switch self {
    //        case .english:
    //            return "ic.english.icon"
    //        case .arabic:
    //            return "ic.arabic.icon"
    //        case .urdu:
    //            return "ic.urdu.icon"
    //        case .hindi:
    //            return "ic.hindi.icon"
    //        }
    //    }
    
    var local: Locale {
        switch self {
        case .english:
            return Locale(identifier: "en")
            //        case .arabic:
            //            return Locale(identifier: "ar")
//        case .urdu:
//            return Locale(identifier: "ur")
            //        case .hindi:
            //            return Locale(identifier: "hi")
        }
    }
    
    var shortCode: String {
        switch self {
        case .english:
            return "EN"
//        case .urdu:
//            return "اردو"
        }
        
    }
    
    var headerKey: String {
        switch self {
        case .english:
            return "en"
//        case .urdu:
//            return "ur"
        }
    }
    
}

