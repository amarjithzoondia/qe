//
//  PDFLoadingOverlay.swift
//  ALNASR
//
//  Created by Amarjith B on 19/11/25.
//


import SwiftUI

struct PDFLoadingOverlay: View {
    var onCancel: (() -> Void)? = nil   // optional cancel callback

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            VStack {
                VStack(spacing: 15) {
                    
                    // Title
                    Text("generating_pdf".localizedString())
                        .font(.poppinsItalic(18))
                        .foregroundColor(.black)
                    
                    // Subtitle
                    Text("generate_pdf_message".localizedString())
                        .font(.lightItalic(11))
                        .foregroundColor(Color.Grey.GUNMENTAL) // slate_grey
                        .multilineTextAlignment(.leading)
                    
                    // Loader (like Android SpinKit ThreeBounce)
                    LoadingOverlay()
                        .frame(width: 50, height: 30)
                        .padding(.top, 8)
                    
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
            }
            .padding(.horizontal, 24)
        }
    }
}


#Preview {
    PDFLoadingOverlay(onCancel: nil)
}
