//
//  SuccessAlertOverlay.swift
//  QualityExpertise
//
//  Created by Amarjith B on 30/08/25.
//

import SwiftUI


struct SuccessAlertOverlay: View {
    var title: String
    let completion: () -> Void
    var body: some View {
        VStack {
            LeftAlignedHStack(
                Text(title)
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.regular(14))
            )
            
            HStack{
                Spacer()
                
                Button {
                    completion()
                } label: {
                    Text("Okay")
                        .foregroundColor(Color.white)
                        .font(.regular(12))
                }
                .frame(width: 80, height: 35)
                .background(Color.Blue.THEME)
                .cornerRadius(17.5)
            }
            .padding(.vertical, 15)
            .padding(.trailing, 15)
        }
    }
}
