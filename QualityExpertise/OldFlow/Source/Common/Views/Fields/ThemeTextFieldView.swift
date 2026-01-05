//
//  ThemeTextFieldView.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//
import SwiftUI

struct ThemeTextFieldView: View {
    @Binding var text: String
    var title: String
    var staticPreText: String? = nil
    var disabled = false
    var keyboardType: UIKeyboardType = .asciiCapable
    var placeholder: String? = nil
    var showTitle = true
    var isMandatoryField = true
    var limit: Int? = nil
    var isSecure = false
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var isDividerShown: Bool? = true
    var foregroundColor: Color = Color.Indigo.DARK
    var placeholderColor: Color = Color.Grey.GUNMENTAL.opacity(0.25)
    var isOptionalTextView = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showTitle {
                HStack(spacing: 2) {
                    Text(title)
                        .foregroundColor(Color.Blue.GREY)
                        .font(.regular(12))
                    
                    if isOptionalTextView {
                        Text("(OPTIONAL)")
                            .foregroundColor(Color.Blue.GREY)
                            .font(.regular(12))
                    }
                    
                    if isMandatoryField {
                        Text("*")
                            .foregroundColor(Color.Red.CORAL)
                            .font(.regular(12))
                    }
                    
                    Spacer()
                }
            }
            
            HStack {
                if let staticPreText = staticPreText {
                    Text(staticPreText)
                        .font(.regular(14))
                        .lineLimit(1)
                }
                
                if isSecure {
                    SecureField(Constants.EMPTY_STRING, text: $text)
                        .onChange(of: text, perform: { value in
                            if let limit = limit {
                                text = value.fieldLimit(limit: limit)
                            }
                        })
                        .keyboardType(keyboardType)
                        .font(.regular(14))
                        .lineLimit(1)
                        .modifier(TextFieldInputViewStyle(placeholder: placeholder ?? title.enterPlaceholder(), foregroundColor: foregroundColor, placeholderColor: placeholderColor, text: $text))
                        .disabled(disabled)
                        .frame(height: 42)
                } else {
                    TextField(Constants.EMPTY_STRING, text: $text)
                        .onChange(of: text, perform: { value in
                            if let limit = limit {
                                text = value.fieldLimit(limit: limit)
                            }
                        })
                        .keyboardType(keyboardType)
                        .font(.regular(14))
                        .lineLimit(1)
                        .modifier(TextFieldInputViewStyle(placeholder: placeholder ?? title.enterPlaceholder(), foregroundColor: foregroundColor, placeholderColor: placeholderColor,text: $text))
                        .disabled(disabled)
                        .autocapitalization(autocapitalizationType)
                        .frame(height: 42)
                }
            }
            
            if isDividerShown ?? true {
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
        }
    }
}

struct ThemeTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeTextFieldView(
            text: .constant(""),
            title: "Title"
        )
    }
}

