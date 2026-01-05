//
//  Font+Extension.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

extension Font {
    
    static func font(name: String, with size: CGFloat) -> Font {
        Font.custom(name, size: size)
    }
    
    static func light(_ size: CGFloat = 12) -> Font {
//        font(name: "Poppins-Light", with: size)
        font(name: "Aptos-Light", with: size)
    }
    
    static func semiBold(_ size: CGFloat = 12) -> Font {
//        font(name: "Poppins-SemiBold", with: size)
        font(name: "Aptos-Bold", with: size)
    }
    
    static func extraBold(_ size: CGFloat = 12) -> Font {
//        font(name: "Poppins-ExtraBold", with: size)
        font(name: "Aptos-ExtraBold", with: size)
    }
    
    static func bold(_ size: CGFloat = 12) -> Font {
//        font(name: "Poppins-Bold", with: size)
        font(name: "Aptos-Bold", with: size)
    }
    
    static func regular(_ size: CGFloat = 12) -> Font {
//        font(name: "Poppins-Regular", with: size)
        font(name: "Aptos", with: size)
    }
    
    static func medium(_ size: CGFloat = 12) -> Font {
//        font(name: "Poppins-Medium", with: size)
        font(name: "Aptos-SemiBold", with: size)
    }
    
}


extension UIFont {
    static func light(size: CGFloat) -> UIFont {
//        return UIFont(name: "Poppins-Light", size: size)!
        return UIFont(name: "Aptos-Light", size: size)!
    }
    
    static func semiBold(size: CGFloat) -> UIFont {
//        return UIFont(name: "Poppins-SemiBold", size: size)!
        return UIFont(name: "Aptos-Bold", size: size)!
    }
    
    static func extraBold(size: CGFloat) -> UIFont {
//        return UIFont(name: "Poppins-ExtraBold", size: size)!
        return UIFont(name: "Aptos-ExtraBold", size: size)!
    }
    
    static func bold(size: CGFloat) -> UIFont {
//        return UIFont(name: "Poppins-Bold", size: size)!
        return UIFont(name: "Aptos-Bold", size: size)!
    }
    
    static func regular(size: CGFloat) -> UIFont {
//        return UIFont(name: "Poppins-Regular", size: size)!
        return UIFont(name: "Aptos", size: size)!
    }
    
    static func medium(size: CGFloat) -> UIFont {
//        return UIFont(name: "Poppins-Medium", size: size)!
        return UIFont(name: "Aptos-Semibold", size: size)!
    }

}
