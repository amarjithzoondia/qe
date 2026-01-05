//
//  CompanyDetails.swift
// ALNASR
//
//  Created by developer on 21/02/22.
//

import Foundation

extension UpdateRequest {
    struct CompanyDetailsParams: Encodable {
        var companyLogo: String
        var companyName: String
    }
    
    struct CompanyDetailsResponse: Decodable {
        var companyLogo: String
        var companyName: String
    }
}
