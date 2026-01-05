//
//  ErrorRetryView.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

struct ErrorRetryView: View {
    var retry: () -> () = {}
    var title: String?
    var message: String
    var isDarkMode: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                retry()
            }, label: {
                VStack(spacing: 3) {
                    Image(systemName: "arrow.clockwise")
                        .renderingMode(.template)
                        .foregroundColor(isDarkMode ? .white : Color.Indigo.DARK)
                }
                    
            })
            .padding(.bottom, 10)
            
            Group {
                if let title = title {
                    Text(title)
                        .font(.semiBold(17))
                        .foregroundColor(isDarkMode ? Color.Blue.THEME : Color.Blue.THEME)
                }
                
                Text(message)
                    .font(.regular())
                    .foregroundColor(isDarkMode ? Color.Blue.THEME : Color.Blue.THEME)
            }
            .multilineTextAlignment(.center)

        }
        .padding(.horizontal, 20)
        .frame(minHeight: 150)
    }
}


