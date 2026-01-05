//
//  ConfirmExitOverlay.swift
//  QualityExpertise
//
//  Created by Amarjith B on 30/08/25.
//

import SwiftUI

struct ConfirmExitOverlay: View {
    @Binding var isPresented: Bool
    var title: String = "Confirm Exit!"
    var message: String = "Are you sure you want to leave this page? All unsaved changes will be lost."
    var onConfirm: () -> Void
    var onCancel: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            LeftAlignedHStack(
                Text(message)
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.regular(14))
            )
            
            HStack {
                Button {
                    isPresented.toggle()
                    onCancel?()
                } label: {
                    Text("No")
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.regular(12))
                        .frame(maxWidth: .infinity, minHeight: 35)
                }
                .background(Color.Grey.PALE)
                .cornerRadius(17.5)
                
                Spacer()
                
                Button {
                    isPresented = false
                    onConfirm()
                } label: {
                    Text("Yes")
                        .foregroundColor(.white)
                        .font(.regular(12))
                        .frame(maxWidth: .infinity, minHeight: 35)
                }
                .background(Color.Blue.THEME)
                .cornerRadius(17.5)
            }
            .padding(.top, 10)
            .padding(.bottom, 15)
        }
    }
}
