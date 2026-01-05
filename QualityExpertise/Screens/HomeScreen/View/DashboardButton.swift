//
//  DashboardButton.swift
//  ALNASR
//
//  Created by Amarjith B on 03/06/25.
//

import SwiftUI

struct DashboardButton<Destination: View>: View {
    let imageName: String
    let title: String
    let backgroundColor: Color
    let destination: Destination?

    var body: some View {
        Group {
            if let destination = destination {
                NavigationLink(destination: destination) {
                    content
                }
            } else {
                content
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(imageName)
                .padding(.top, 10)

            Text(title)
                .font(.medium(15))
                .padding(.bottom, 9)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, minHeight: 135)
        .padding(.horizontal, 20)
        .background(backgroundColor)
        .cornerRadius(24)
    }
}



