//
//  TextFieldInputStyle.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

struct TextFieldInputViewStyle: ViewModifier {
    
    var placeholder: String = ""
    var font: Font = .regular(12)
    var foregroundColor: Color = Color.Indigo.DARK
    var placeholderColor: Color = Color.Grey.GUNMENTAL.opacity(0.25)
    var height: CGFloat = 41
    var alignment: TextAlignment = .leading
    @Binding var text: String
     
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(foregroundColor)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .multilineTextAlignment(alignment)
                    .foregroundColor(placeholderColor)
                    .font(font)
            }
            .frame(height: height)
    }
}
