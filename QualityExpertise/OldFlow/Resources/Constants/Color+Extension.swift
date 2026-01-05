//
//  Color+Extension.swift
// ALNASR
//
//  Created by developer on 18/01/22.
//

import Foundation
import SwiftUI

extension Color {
    struct Blue {
        public static var THEME: Color {
            Color(hex: "00517e")
        }
        
        public static var ELECTRIC: Color {
            Color(hex: "0d54f7")
        }
        
        public static var POWDERED_76: Color {
            Color("cl.powdered.76%")
        }
        
        public static var GREY: Color {
            Color(hex: "8c94a9")
        }
        
        public static var DARK_BLUE_GREY: Color {
            Color(hex: "1b2343")
        }
        
        public static var CAROLINA: Color {
            Color(hex: "85abfe")
        }
        
        public static var CORN_FLOWER: Color {
            Color(hex: "836bfd")
        }
        
        public static var VERY_LIGHT: Color {
            Color(hex: "e5e8ef")
        }
        
        public static var PALE_GREY: Color {
            Color(hex: "e3ebff")
        }
        
        public static var BLUE_GREY: Color {
            Color(hex: "5d698c")
        }
        
        public static var LIGHT_BLUE_GREY: Color {
            Color(hex: "b0b5b8")
        }
        
        public static var BRIGHT_SKY_BLUE: Color {
            Color(hex: "00b7ff")
        }
        
        public static var BRIGHT_CYAN_TWO: Color {
            Color(hex: "43ccff")
        }
        
        public static var ICE: Color {
            Color(hex: "e4f7ff")
        }
        
        public static var PALE: Color {
            Color(hex: "f5f6ff")
        }
        
        public static var LIGHT_BLUE: Color {
            Color("cl.lightBlue")
        }
    }
    
    struct Grey {
        public static var GUNMENTAL: Color {
            Color(hex: "494e5e")
        }
        
        public static var PALE: Color {
            Color(hex: "eff1f6")
        }
        
        public static var DARK_BLUE: Color {
            Color(hex: "183340")
        }
        
        public static var LIGHT_PERIWINKLE: Color {
            Color(hex: "d3d8e1")
        }
        
        public static var SLATE: Color {
            Color(hex: "62687e")
        }
        
        public static var PALE_THREE: Color {
            Color(hex: "f4f5f7")
        }
        
        public static var STEEL: Color {
            Color(hex: "808392")
        }
        
        public static var LIGHT_GREY_BLUE: Color {
            Color(hex: "a7adbe")
        }
        
        public static var BLUEY_GREY: Color {
            Color(hex: "9c9da4")
        }
        
        public static var PALE_FIVE: Color {
            Color(hex: "e5e5ec")
        }
    }
    
    struct Red {
        public static var LIGHT: Color {
            Color(hex: "FF1744")
        }
        
        public static var WHEAT: Color {
            Color(hex: "fed476")
        }
        
        public static var SALMON: Color {
            Color(hex: "ff846b")
        }
        
        public static var CORAL: Color {
            Color(hex: "fa6345")
        }
        
        public static var VERY_LIGHT_PINK: Color {
            Color(hex: "ffebe1")
        }
    }
    
    struct Indigo {
        public static var DARK: Color {
            Color(hex: "10245b")
        }
        
        public static var DUSK_FOUR_15: Color {
            Color("cl.dusk.four.15%")
        }
    }
    
    struct Black {
        public static var DARK: Color {
            Color(hex: "23293b")
        }
        
        public static var BLACK_2: Color {
            Color("cl.black.2%")
        }
        
        public static var DUSK_TWO: Color {
            Color(hex: "474361")
        }
    }
    
    struct Silver {
        public static var TWO: Color {
            Color(hex: "e9e9ea")
        }
    }
    
    struct Green {
        public static var DARK_GREEN: Color {
            Color(hex: "00703c")
        }
        
        public static var SOFT: Color {
            Color(hex: "5ec67d")
        }
        
        public static var DARK_MINT: Color {
            Color(hex: "3dc7a0")
        }
        
        public static var LEAFY: Color {
            Color(hex: "45b743")
        }
        
        public static var GREEN_BLUE: Color {
            Color(hex: "28d29f")
        }
        
        public static var ICE: Color {
            Color(hex: "e6faf8")
        }
    }
    
    struct Orange {
        public static var PINK: Color {
            Color(hex: "fc6a5d")
        }
        
        public static var MACRONI_AND_CHEESE: Color {
            Color(hex: "f7b231")
        }
        
        public static var PALE: Color {
            Color(hex: "fdf0d8")
        }
        
        public static var LIGHT_ORANGE: Color {
            Color("cl.lightOrange")
        }
    }
    
    struct Pink {
        public static var LIGHT: Color {
            Color(hex: "ffdedb")
        }
    }
    
    struct Violet {
        public static var CORN_FLOWER: Color {
            Color(hex: "536dff")
        }
        
        public static var LIGHT_VIOLET: Color {
            Color("cl.lightViolet")
        }
    }
    
    struct Yellow {
        public static var LIGHT_YELLOW: Color {
            Color("cl.lightYellow")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
