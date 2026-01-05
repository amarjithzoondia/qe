//
//  Project.swift
//  QualityExpertise
//
//  Created by Amarjith B on 09/04/25.
//

import Foundation

struct Project : Decodable, Hashable,Identifiable {
    let id:Int
    let name:String
    let code:String
    let clientName:String?
    let image:String
    let location:String
    let projectDescription:String?
    
    static func dummy() -> Project {
        .init(id: 0, name: "Dummy Project", code: "001", clientName: "Sample", image: "", location: "",projectDescription: "")
    }
}

struct ProjectListParams : Codable {
    let name: String?
}


