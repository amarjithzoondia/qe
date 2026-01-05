//
//  WebUrlImage.swift
//  ALNASR
//
//  Created by developer on 20/01/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WebUrlImage: View {
    private var isResizable = true
    var url: URL?
    var placeholderImage: Image

    var body: some View {
        WebImage(url: url, options: [.scaleDownLargeImages])
            .cancelOnDisappear(true)
            .placeholder {
                placeholderImage
            }
            .resizable()
//            .aspectRatio(contentMode: .fill)
    }

    init(
        isResizable: Bool = true,
        url: URL? = nil,
        placeholderImage: Image = Image(IC.PLACEHOLDER.COMMON),
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) {
        self.isResizable = isResizable
        self.url = url
        self.placeholderImage = placeholderImage.resizable()
    }

    func resizable() -> WebUrlImage {
        return WebUrlImage(isResizable: true, url: self.url, placeholderImage: self.placeholderImage )
    }
}
