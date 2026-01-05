//
//  NavigationBackButton.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

struct NavigationBackButton: View {
    var action: () -> () = {}
    var image = Image(IC.INDICATORS.BLACK_BACKWARD_ARROW)

    var body: some View {
        Button(action: {
            action()
        }) {
            image
        }
        //.padding(.leading, 17)
    }
}

struct NavigationBackButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBackButton()
    }
}

