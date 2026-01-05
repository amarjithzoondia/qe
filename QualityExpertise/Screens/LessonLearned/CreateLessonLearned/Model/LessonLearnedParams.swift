//
//  LessonLearnedParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/07/25.
//

struct LessonLearnedParams: Codable {
    var facilitiesId: String?
    var title: String
    var description: String?
    var images: [ImageData]?
    var reportedBy: String
}

struct LessonLearnedCreationResponse: Codable {
    let lessonId: Int
    let statusMessage: String
}
