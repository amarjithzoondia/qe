//
//  ViolationPdfParams.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

struct ViolationPdfParams: Codable {
    var violationId: Int
}

struct ViolationPdfResponse: Decodable {
    var pdfUrl: String
}
