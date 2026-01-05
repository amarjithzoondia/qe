//
//  ImageData.swift
// QualityExpertise
//
//  Created by developer on 07/02/22.
//

import Foundation

struct ImageData: Codable, Equatable, Identifiable {
    var id: Int?
    var image: String?
    var imageCount: Int?
    var description: String?
}

extension ImageData {
    static func dummy(imageCount: Int) -> ImageData {
        ImageData(id: nil, image: "", imageCount: imageCount, description: "")
    }
}

extension ImageData {
    var isDummy: Bool {
        id == nil && (image?.isEmpty ?? true)
    }
}
