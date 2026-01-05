//
//  LessonLearnedPdfParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/07/25.
//

struct LessonLearnedPdfParams: Codable {
    var lessonId: Int
}

struct LessonLearnedPdfResponse: Decodable {
    var pdfUrl: String
}
