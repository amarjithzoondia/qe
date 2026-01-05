//
//  SearcGroupInputView.swift
// ALNASR
//
//  Created by developer on 28/01/22.
//

import SwiftUI
import Introspect

struct SearchFieldInputView: View {
    var onEditingChanged: () -> ()
    var onDone: () -> ()
    @Binding var text: String
    var placeholder: String = "Search"
    var closeButtonActive: Bool
    var image: String?
    var foregroundColor: Color = Color.Blue.DARK_BLUE_GREY
    var font: Font = .regular(12)
    var background: Color = Color.Grey.PALE
    var placeholderColor: Color = Color.Grey.GUNMENTAL.opacity(0.25)
    var onCloseClicked: () -> () = {}
    
    var body: some View {
        return HStack {
            Image(image ?? IC.ACTIONS.SEARCH)
                .foregroundColor(Color.Green.DARK_GREEN)
                .padding(.leading, 14.5)
            
            TextField("", text: $text, onEditingChanged: { text in
                onEditingChanged()
            }, onCommit: {
                onDone()
            })
                .modifier(TextFieldInputViewStyle(placeholder: placeholder, font: font, foregroundColor: foregroundColor, placeholderColor: placeholderColor, text: $text))
            .introspectTextField { textfield in
                textfield.returnKeyType = .done
            }
            .padding(.leading, 11.5)
            
            Spacer()
            
            if closeButtonActive {
                Button {
                    text = ""
                    onCloseClicked()
                } label: {
                    Image(IC.ACTIONS.CLOSE)
                }
                .padding(.trailing, 11.5)
            }
        }
        .frame(height: 41)
        .background(background)
        .cornerRadius(25)
    }
}

