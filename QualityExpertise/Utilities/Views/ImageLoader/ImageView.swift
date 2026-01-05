//
//  ImageView.swift
//  VM
//
//  Created by Vivek M on 08/02/22.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage(named: IC.PLACEHOLDER.COMMON)!

    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
    }

    var body: some View {
        
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage(named: IC.PLACEHOLDER.COMMON)!
        }
    }
}
