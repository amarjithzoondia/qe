//
//  ThemeTextEditorView.swift
// ALNASR
//
//  Created by developer on 26/01/22.
//

import SwiftUI

struct ThemeTextEditorView: View {
     @Binding var text: String
     var title: String
     var disabled: Bool? = false
     var keyboardType: UIKeyboardType? = .asciiCapable
     var isMandatoryField: Bool? = true
     var limit: Int? = nil
     var placeholderColor: Color? = Color.Grey.GUNMENTAL.opacity(0.25)
     var isTitleCapital: Bool = true
     
          let minHeight: CGFloat = 42
          @State private var textViewHeight: CGFloat?
     
     init(text: Binding<String>, title: String, disabled: Bool?, keyboardType: UIKeyboardType?, isMandatoryField: Bool?, limit: Int?, placeholderColor: Color?, isTitleCapital: Bool) {
          self._text = text
          self.title = title
          self.keyboardType = keyboardType
          self.disabled = disabled
          self.isMandatoryField = isMandatoryField
          self.limit = limit
          self.placeholderColor = placeholderColor
          self.isTitleCapital = isTitleCapital
          UITextView.appearance().backgroundColor = .clear
     }
     
     var body: some View {
          VStack(spacing: 4) {
               
               LeftAlignedHStack(
                    (Text(title).foregroundColor(Color.Blue.GREY)
                         .font(.regular(12)))
               )
               
               ZStack(alignment: .leading) {
                    if text == "" {
                         Text(title.enterPlaceholder(isCapital: isTitleCapital))
                              .font(.regular(12))
                              .foregroundColor(placeholderColor)
                    }
                    ResizableTextView(text: $text, textDidChange: self.textDidChange)
                                   .frame(height: textViewHeight ?? minHeight)
                                   .offset(x: -3, y: 2)
               }
               
               Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
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


