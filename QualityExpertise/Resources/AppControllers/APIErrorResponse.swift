//
//  APIErrorResponse.swift
//  QualityExpertise
//
//  Created by Amarjith B on 08/09/25.
//

struct APIErrorResponse: Decodable {
    let hasError: Bool
    let errorCode: Int?
    let message: String?
    let response: DebugResponse?

    struct DebugResponse: Decodable {
        let debugMessage: String?
    }
}
