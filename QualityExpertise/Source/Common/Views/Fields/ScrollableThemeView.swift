//
//  ScrollableThemeView.swift
// QualityExpertise
//
//  Created by developer on 21/01/22.
//

import SwiftUI

import SwiftUI

struct ScrollContainerStatusBarView<Content: View>: View {
    let statusBarColor: Color
    let backgroundColor: Color
    let content: Content
    
    init(
        statusBarColor: Color = Color.Blue.THEME,
        backgroundColor: Color = Color.Blue.THEME,
        @ViewBuilder content: () -> Content
    ) {
        self.statusBarColor = statusBarColor
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                statusBarColor
                    .edgesIgnoringSafeArea(.top)
                
                Spacer(minLength: 0.1)
                
                content
                    .frame(height: geometry.size.height)
                    .edgesIgnoringSafeArea(.bottom)

            }
            .background(backgroundColor)
        }
    }
}
