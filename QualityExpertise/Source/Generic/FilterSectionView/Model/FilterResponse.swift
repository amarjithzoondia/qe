//
//  FilterResponse.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/10/25.
//

struct FilterResponse: Codable {
    let projects: [GroupData]
    let responsiblePersons: [UserData]
}
