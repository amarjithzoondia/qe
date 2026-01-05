//
//  ToolBoxPdfParams.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

struct ToolBoxPdfParams: Codable {
    var toolBoxId: Int
}

struct ToolBoxPdfResponse: Decodable {
    var pdfUrl: String
}
