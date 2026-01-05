//
//  StaticEquipment.swift
//  ALNASR
//
//  Created by Amarjith B on 02/06/25.
//

import Foundation

struct EquipmentStatic:Identifiable, Hashable, Codable {
    var id: Int
    var title: String
    var selectedValue: StaticEquipmentOptions?
    
    
    static func dummy() -> EquipmentStatic {
        return EquipmentStatic(id: -1, title: "Who Are You ?")
    }
}


struct EquipmentStaticResponse: Codable {
    var updatedTime: String?
//    var formVersion: String
    var type: Int?
    var contents : [EquipmentStatic]
}
