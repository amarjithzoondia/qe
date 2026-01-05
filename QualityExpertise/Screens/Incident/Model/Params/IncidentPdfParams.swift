//
//  IncidentPdfParams.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

struct IncidentPdfParams: Codable {
    var incidentId: Int
}

struct IncidentPdfResponse: Decodable {
    var pdfUrl: String
}
