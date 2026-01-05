//
//  LoadingOverlay.swift
//  ALNASR
//
//  Created by Amarjith B on 05/06/25.
//
import SwiftUI
import SwiftfulLoadingIndicators

struct LoadingOverlay: View {
    var body: some View {
        Color.white.opacity(0.25)
            .edgesIgnoringSafeArea(.all)
        
        LoadingIndicator(
            animation: .threeBalls,
            color: Color.Blue.THEME,
            size: .medium,
            speed: .normal
        )
    }
}
