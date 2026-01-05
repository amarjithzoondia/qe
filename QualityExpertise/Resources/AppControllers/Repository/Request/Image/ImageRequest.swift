//
//  ImageRequest.swift
// QualityExpertise
//
//  Created by developer on 20/01/22.
//

import SwiftUI

enum ImageUploadRequest {
    case profileImage(image: UIImage)
    case observationImage(image: UIImage)
    case groupImage(image: UIImage)
    case companyLogo(image: UIImage)
    case inspectionImage(image: UIImage)
    case violationImage(image: UIImage)
    case lessonLearnedImage(image: UIImage)
    case incidentImage(image: UIImage)
    case toolBoxImage(image: UIImage)
    case preTaskImage(image: UIImage)

    var type: String {
        switch self {
        case .profileImage(_):
            return "1"
        case .observationImage(_):
            return "2"
        case .groupImage(_):
            return "3"
        case .companyLogo(_):
            return "4"
        case .inspectionImage(_):
            return "5"
        case .violationImage(_):
            return "6"
        case .lessonLearnedImage(_):
            return "7"
        case .incidentImage(_):
            return "8"
        case .toolBoxImage(_):
            return "9"
        case .preTaskImage(_):
            return "10"
        }
    }
}

extension ImageUploadRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        nil
    }
    
    var endpoint: String {
        "upload-image"
    }
    
    var params: Encodable? {
        Params(type: type)
    }
    
    var imageData: Data? {
        switch self {
        
        case .profileImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .observationImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .groupImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .companyLogo(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .inspectionImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .violationImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .lessonLearnedImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .incidentImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .toolBoxImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        case .preTaskImage(image: let image):
            return image.jpegData(compressionQuality: 0.5)
        }
    }
}
