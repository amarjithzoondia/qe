//
//  GuestCompanyDetails.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import Foundation

extension GuestRequest {
    struct GusetCompanyParams: Encodable {
        var guestUserId: Int
        var companyLogo: String
        var companyName: String
    }
    
    struct GuestComapnyResponse: Decodable {
        var companyLogo: String
        var companyName: String
    }
}
