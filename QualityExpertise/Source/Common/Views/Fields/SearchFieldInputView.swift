//
//  SearcGroupInputView.swift
// QualityExpertise
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
        HStack {
            // 🔎 Search icon
            Image(image ?? IC.ACTIONS.SEARCH)
                .foregroundColor(Color.Green.DARK_GREEN)
                .padding(.leading, 14.5)

            // 🔥 UIKit TextField replacing SwiftUI TextField
            UIKitStyledTextField(
                text: $text,
                placeholder: placeholder,
                font: UIFont.systemFont(ofSize: 12),
                textColor: UIColor(foregroundColor),
                placeholderColor: UIColor(placeholderColor),
                height: 41,
                isRTL: LocalizationService.shared.language.isRTLLanguage,
                keyboardType: .default
            )
            .padding(.leading, 11.5)
            .introspectViewController { vc in
                // This gives us access to UITextField inside UIKit component
                if let tf = vc.view.subviews.first(where: { $0 is UITextField }) as? UITextField {
                    tf.returnKeyType = .done
                }
            }

            Spacer()

            // ❌ Close button
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
