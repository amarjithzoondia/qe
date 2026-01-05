//
//  ResizableTextView.swift
// QualityExpertise
//
//  Created by Developer on 17/03/22.
//

import SwiftUI
import UIKit

struct ResizableTextView: UIViewRepresentable {

    typealias UIViewType = UITextView

    @Binding var text: String

    var onBeginEditing: (() -> Void)? = nil
    let textDidChange: (UITextView) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            onBeginEditing: onBeginEditing,
            textDidChange: textDidChange
        )
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = true
        view.isScrollEnabled = true     // ✅ required for resizing
        view.font = .regular(size: 14)
        view.textColor = Color.Indigo.DARK.toUIColor()
        view.delegate = context.coordinator
        view.backgroundColor = .clear

        if LocalizationService.shared.language.isRTLLanguage {
            view.textAlignment = .right
            view.semanticContentAttribute = .forceRightToLeft
        } else {
            view.textAlignment = .left
            view.semanticContentAttribute = .forceLeftToRight
        }

        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // ✅ Prevent jumpy cursor & scroll
        if uiView.text != text && !uiView.isFirstResponder {
            uiView.text = text
        }

        DispatchQueue.main.async {
            self.textDidChange(uiView)
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {

        @Binding var text: String
        var onBeginEditing: (() -> Void)?
        let textDidChange: (UITextView) -> Void

        init(
            text: Binding<String>,
            onBeginEditing: (() -> Void)?,
            textDidChange: @escaping (UITextView) -> Void
        ) {
            self._text = text
            self.onBeginEditing = onBeginEditing
            self.textDidChange = textDidChange
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            onBeginEditing?()
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            textDidChange(textView)
        }
    }
}
