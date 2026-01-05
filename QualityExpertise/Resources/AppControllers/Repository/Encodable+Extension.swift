//
//  Encodable+Extension.swift
// QualityExpertise
//
//  Created by Vivek M on 17/09/21.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return dictionary
        } catch let err {
            Log.print("Parsing Error", err)
            return nil
        }
    }
}

