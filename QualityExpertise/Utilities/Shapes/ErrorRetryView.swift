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
    var isError: Bool = false

    // MARK: - Computed Colors
    private var iconColor: Color {
        isError ? .red : (isDarkMode ? .white : Color.Indigo.DARK)
    }

    private var textColor: Color {
        isError ? .red : Color.Blue.THEME
    }

    var body: some View {
        VStack {
            Button(action: {
                retry()
            }) {
                VStack(spacing: 3) {
                    Image(systemName: "arrow.clockwise")
                        .renderingMode(.template)
                        .foregroundColor(iconColor) // ✅ red if error
                }
            }
            .padding(.bottom, 10)

            Group {
                if let title = title {
                    Text(title)
                        .font(.semiBold(17))
                        .foregroundColor(textColor) // ✅ red if error
                }

                Text(message)
                    .font(.regular())
                    .foregroundColor(textColor) // ✅ red if error
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 150)
    }
}
