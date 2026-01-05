//
//  BackBarButtonItem.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

struct BackButtonToolBarItem: ToolbarContent {
    var action: () -> () = {}
    var image: Image?

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            NavigationBackButton(
                action: action,
                image: Image(IC.INDICATORS.BLACK_BACKWARD_ARROW)
            )
        }
    }


    
    struct NavigationBackButton: View {
        var action: () -> ()
        var image: Image
        @Environment(\.layoutDirection) private var layoutDirection

        var body: some View {
            Button(action: action) {
                image
                    .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
            }
        }
    }

}

