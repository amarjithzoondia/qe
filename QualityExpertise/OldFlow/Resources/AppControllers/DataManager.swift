//
//  DataManager.swift
// ALNASR
//
//  Created by developer on 16/03/22.
//

import Foundation
 
class DataManager {

}

extension DataManager {
    class func parse<T:Codable>(data: Any, to classType: T.Type) -> Any? {
        do {
            if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                let decoder = JSONDecoder()
                return try decoder.decode(classType, from: jsonData)
            }
            return nil
        } catch let err {
            print("Parsing Error", err)
            return nil
        }
    }
}

extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }

    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}

extension String {
    var dictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

