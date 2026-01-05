//
//  LogoTabItemView.swift
// ALNASR
//
//  Created by developer on 26/01/22.
//

import SwiftUI

struct LogoTabItemView: View {
    static let HEIGHT: CGFloat = 63
    //var action: () -> () = {}

    var body: some View {
        ZStack {
            LogoContainerShape()
                .fill(Color.clear)
                
            VStack(spacing: 0) {
                
                Image(IC.DASHBOARD.TAB.LOGO)
                    .resizable()
                    .frame(width: 62, height: 62)
            }
        }
        .frame(height: LogoTabItemView.HEIGHT)
        .background(Color.clear)
    }
}

struct SearchTabItemView_Previews: PreviewProvider {
    static var previews: some View {
        LogoTabItemView()
    }
}
