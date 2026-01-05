//
//  CircularDownloadProgressView.swift
//  ALNASR
//
//  Created by Amarjith B on 19/11/25.
//

import SwiftUI

struct CircularDownloadProgressView: View {
    var progress: Double       // 0.0 → 1.0
    var color: Color = Color.Blue.THEME
    var language: Language = LocalizationService.shared.language
    var body: some View {
            ZStack {
                
                // Background ring
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                
                // Progress ring
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(language.isRTLLanguage ? 90 : -90))    // FIXED: Starts from top
                    .animation(.easeInOut(duration: 0.25), value: progress)
                
                // Arrow at center
                Image(systemName: "arrow.down")
                    .foregroundColor(color)
                    .font(.system(size: 8, weight: .bold))
            }
            .frame(width: 25, height: 25)
        
           
    }
}
