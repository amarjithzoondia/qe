//
//  GeneralRequest+Extension.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import Foundation

extension GeneralRequest {
    struct StaticContentParams: Encodable {
        let type: StaticContentType
    }
    
    struct StaticContentResponse: Decodable {
        let content: String
    }
}
