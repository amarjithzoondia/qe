//
//  URLImage.swift
//  VM
//
//  Created by Vivek M on 08/02/22.
//

import SwiftUI

struct URLImage: View {
    var url: String
    var contentMode: ContentMode = .fit
    var maxWidth: CGFloat? = nil
    var maxHeight: CGFloat? = nil
    
    var body: some View {
        if #available(iOS 15.0, *) {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: contentMode)
                         .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                case .failure:
                    Image(IC.PLACEHOLDER.COMMON)
                @unknown default:
                    // Since the AsyncImagePhase enum isn't frozen,
                    // we need to add this currently unused fallback
                    // to handle any new cases that might be added
                    // in the future:
                    Image(IC.PLACEHOLDER.COMMON)
                }
            }
        } else {
            ImageView(withURL: url)
        }
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(url: "")
    }
}
