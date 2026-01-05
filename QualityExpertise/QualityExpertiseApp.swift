//
//  QualityExpertiseApp.swift
//  QualityExpertise
//
//  Created by Apple on 17/01/22.
//

import SwiftUI

 @main
struct QualityExpertiseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            SplashContentView()
                .id(appState.appId)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                .localize()
        }
    }
    init() {
        NavigationAppearance.setTabbarApperance()
        NavigationAppearance.setThemeNavigationStyle()
        UITabBar.appearance().isHidden = true
    }
}
