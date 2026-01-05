//
//  DrawsanaAnnotatorView.swift
//  ALNASR
//
//  Created by Amarjith B on 13/11/25.
//

import SwiftUI

struct ModernDrawsanaWrapper: UIViewControllerRepresentable {
    let image: UIImage
    var onDone: (UIImage) -> Void
    var onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> DrawsanaEditorWithTopBar {
        return DrawsanaEditorWithTopBar(
            image: image,
            onDone: { img in
                onDone(img)        // ← pass the final image
            },
            onCancel: {
                onCancel()
            }
        )
    }
    
    func updateUIViewController(_ uiViewController: DrawsanaEditorWithTopBar, context: Context) {}
}



