//
//  LeftAlignModifier.swift
// ALNASRScanning
//
//  Created by Apple on 13/12/21.
//

import SwiftUI

extension View {
    func leftAlign() -> some View {
        self.modifier(LeftAlignModifier())
    }
}

struct LeftAlignModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            
            Spacer()
        }
    }
}
