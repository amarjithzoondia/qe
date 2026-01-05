//
//  View+Extension.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

extension View {
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}

extension View {
    func closeKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),to: nil, from: nil, for: nil)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCornerShape(radius: radius, corners: corners) )
    }
}

extension View {
    func verticalCenter() -> some View {
        VStack {
            Spacer()
            self
            Spacer()
        }
    }
}
