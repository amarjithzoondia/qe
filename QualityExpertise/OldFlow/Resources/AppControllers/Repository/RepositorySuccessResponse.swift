//
//  RepositorySuccessResponse.swift
// ALNASR
//
//  Created by Vivek M on 09/06/21.
//

import Foundation

extension RepositoryManager {    
    struct SuccessResponse: Codable {
        let hasError: Bool
        let errorCode: Int
        let message: String?
    }
}
