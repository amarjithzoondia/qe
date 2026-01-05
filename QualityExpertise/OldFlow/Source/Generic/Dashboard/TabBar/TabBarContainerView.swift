//
//  TabBarContainerView.swift
// ALNASR
//
//  Created by developer on 26/01/22.
//
import SwiftUI

struct TabBarContainerView<Content: View>: View {
    let content: Content
    let contentVisible: Bool

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { reader in
                let frame = reader.frame(in: .local)
                if contentVisible {
                    content
                        .frame(width: frame.width,
                               height: frame.height,
                               alignment: .center)
                }
            }
        }
    }
}

struct TabBarContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarContainerView(content: Color.green, contentVisible: true)
    }
}
