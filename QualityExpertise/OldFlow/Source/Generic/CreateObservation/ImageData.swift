//
//  ImageData.swift
// ALNASR
//
//  Created by developer on 07/02/22.
//

import Foundation

struct ImageData: Codable, Equatable, Identifiable {
    internal init(id: Int?, image: String, imageCount: Int, description: String) {
        self.id = id
        self.image = image
        self.imageCount = imageCount
        self.description = description
    }
    
    var id: Int?
    var image: String?
    var imageCount: Int?
    var description: String
}
extension ImageData {
    static func dummy(imageCount: Int) -> ImageData {
        ImageData(id: nil, image: "", imageCount: imageCount, description: "")
    }
}
