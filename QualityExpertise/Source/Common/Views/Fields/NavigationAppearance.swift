//
//  NavigationAppearance.swift
// QualityExpertise
//
//  Created by developer on 20/01/22.
//

import UIKit
import SwiftUI

struct NavigationAppearance {
    static func setThemeNavigationStyle() {
        // this is not the same as manipulating the proxy directly
        let appearance = UINavigationBarAppearance()
        
        // this overrides everything you have set up earlier.
        //appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor.clear
        
        // this only applies to big titles
        appearance.largeTitleTextAttributes = [
            .font : UIFont.semiBold(size: 20),
            .foregroundColor : UIColor.black
        ]
        // this only applies to small titles
        appearance.titleTextAttributes = [
            .font : UIFont.semiBold(size: 20),
            .foregroundColor : UIColor.black
        ]
        
//        let backImage = UIImage(named: "ic.navigation.back.arrow.white")
//        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        
        //In the following two lines you make sure that you apply the style for good
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
        // This property is not present on the UINavigationBarAppearance
        // object for some reason and you have to leave it til the end
        //UINavigationBar.appearance().tintColor = .white
    }
    
    static func setTransparentNavigationStyle() {
        // this is not the same as manipulating the proxy directly
        let appearance = UINavigationBarAppearance()
        
        // this overrides everything you have set up earlier.
        appearance.configureWithTransparentBackground()
        //appearance.backgroundColor = UIColor.clear
        appearance.shadowColor = UIColor.clear
        
        // this only applies to big titles
        appearance.largeTitleTextAttributes = [
            .font : UIFont.semiBold(size: 20),
            .foregroundColor : UIColor.white
        ]
        // this only applies to small titles
        appearance.titleTextAttributes = [
            .font : UIFont.semiBold(size: 20),
            .foregroundColor : UIColor.white
        ]
        
        //In the following two lines you make sure that you apply the style for good
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
        // This property is not present on the UINavigationBarAppearance
        // object for some reason and you have to leave it til the end
        UINavigationBar.appearance().tintColor = .white
    }
    
    static func setTabbarApperance() {
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().barTintColor = .white //UIColor.Blue.THEME
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .white //UIColor.Blue.THEME
        UITabBar.appearance().standardAppearance = appearance
    }
}
