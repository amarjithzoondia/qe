//
//  DraftObservationResponse.swift
//  QualityExpertise
//
//  Created by Amarjith B on 12/06/25.
//

struct DraftObservationResponse: Decodable {
    let observations: [ObservationDraftData]
}

struct DeleteDraftParams: Encodable {
    let id: Int
}
