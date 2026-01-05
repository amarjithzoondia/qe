//
//  RoundedCornerShape.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

/// used for custom corner radius for specific corners
struct RoundedCornerShape: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
