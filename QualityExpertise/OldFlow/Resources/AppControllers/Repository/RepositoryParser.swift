//
//  RepositoryParser.swift
// ALNASR
//
//  Created by Developer on 03/08/21.
//

import Foundation

struct RepositoryParser {
    static func parse<T:Decodable>(data: Any, to classType: T.Type) -> Any? {
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                let decoder = JSONDecoder()
                return try decoder.decode(classType, from: jsonData)
            }
            return nil
        } catch let err {
            Log.print("Parsing Error", err)
            return nil
        }
    }
}
