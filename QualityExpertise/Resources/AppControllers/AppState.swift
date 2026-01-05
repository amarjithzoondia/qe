//
//  AppState.swift
// QualityExpertise
//
//  Created by Apple on 29/11/21.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var appId = UUID()

    class func resetApp() {
        DispatchQueue.main.async {
            AppState.shared.appId = UUID()
        }
    }
}


