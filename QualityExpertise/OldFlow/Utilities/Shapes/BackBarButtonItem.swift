//
//  BackBarButtonItem.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

struct BackButtonToolBarItem: ToolbarContent {
    var action: () -> () = {}
    var image = Image(IC.INDICATORS.BLACK_BACKWARD_ARROW)
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            NavigationBackButton(
                action: {
                    action()
                },
                image: image
            )
            
        }
    }
}
