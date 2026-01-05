//
//  ThemeTextEditorView.swift
// QualityExpertise
//
//  Created by developer on 26/01/22.
//

import SwiftUI

struct ThemeTextEditorView: View {
     @Binding var text: String
     var title: String
     var placeholder: String? = nil
     var disabled: Bool = false
     var keyboardType: UIKeyboardType? = .default
     var isMandatoryField: Bool? = true
     var limit: Int? = nil
     var placeholderColor: Color? = Color.Grey.GUNMENTAL.opacity(0.25)
     var isTitleCapital: Bool = true
     var isDividerShown: Bool = true
     var isPlaceHolderShown: Bool = true
     var isOptionalTextView: Bool = false
     var isSecure: Bool = false
          let minHeight: CGFloat = 42
          @State private var textViewHeight: CGFloat?
     
     init(text: Binding<String>, title: String, placeholder: String? = nil, disabled: Bool = false, keyboardType: UIKeyboardType? = .default, isMandatoryField: Bool? = false, limit: Int? = nil, placeholderColor: Color? = nil, isTitleCapital: Bool = false, isDividerShown: Bool = true, isPlaceHolderShown: Bool = true, isOptionalTextView: Bool = false, isSecure: Bool = false) {
          self._text = text
          self.title = title
          self.placeholder = placeholder
          self.keyboardType = .default
          self.disabled = disabled
          self.isMandatoryField = isMandatoryField
          self.limit = limit
          self.placeholderColor = placeholderColor
          self.isTitleCapital = isTitleCapital
          self.isDividerShown = isDividerShown
          self.isPlaceHolderShown = isPlaceHolderShown
          self.isOptionalTextView = isOptionalTextView
          self.isSecure = isSecure
          UITextView.appearance().backgroundColor = .clear
     }
     
     var body: some View {
          VStack(spacing: 4) {
               
               HStack(spacing: 2) {
                    (Text(title).foregroundColor(Color.Blue.GREY)
                         .font(.regular(12)))
                    
                    if isOptionalTextView {
                        Text("optional".localizedString())
                            .foregroundColor(Color.Blue.GREY)
                            .font(.regular(12))
                    }
                    
                    if let mandatory = isMandatoryField, mandatory {
                         Text("*")
                             .foregroundColor(Color.Red.CORAL)
                             .font(.regular(12))
                    }
                    
                    Spacer()
               }
               
               ZStack(alignment: .leading) {
                    if text == "" && isPlaceHolderShown {
                         if let placeholder {
                              Text(placeholder)
                                   .font(.regular(12))
                                   .foregroundColor(Color.Grey.GUNMENTAL.opacity(0.25))
                         } else {
                              Text(title.enterPlaceholder(isCapital: true))
                                   .font(.regular(12))
                                   .foregroundColor(Color.Grey.GUNMENTAL.opacity(0.25))
                         }
                    }
                    if isSecure {
                         UIKitPasswordField(
                             text: $text,
                             placeholder: title.enterPlaceholder(isCapital: true),
                             isSecure: true,
                             font: .regular(size: 12),
                             textColor: UIColor(Color.Indigo.DARK),
                             placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                             isRTL: LocalizationService.shared.language.isRTLLanguage,
                             isPlaceholderShown: false
                         )
                         .disabled(disabled)
                         .frame(maxWidth: .infinity)
                         .frame(height: textViewHeight ?? minHeight)
                         .offset(x: -3, y: 2)
                    } else {
                         ResizableTextView(text: $text, textDidChange: self.textDidChange)
                              .frame(maxWidth: .infinity)
                              .frame(height: textViewHeight ?? minHeight)
                              .offset(x: -3, y: 2)
                              .disabled(disabled)
                    }
               }
               if isDividerShown {
                    Divider()
                         .frame(height: 1)
                         .foregroundColor(Color.Silver.TWO)
               }
          }
     }
     private func textDidChange(_ textView: UITextView) {
               self.textViewHeight = max(textView.contentSize.height, minHeight)
          }
}



struct ThemeTextEditorView_Previews: PreviewProvider {
     static var previews: some View {
          ThemeTextEditorView(text: .constant(""), title: "", disabled: false, keyboardType: .asciiCapable, isMandatoryField: false, limit: -1, placeholderColor: nil, isTitleCapital: true)
     }
}


