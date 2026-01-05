//
//  ToolBoxTalkDBRepositoryProtocol.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

protocol ToolBoxTalkDBRepositoryProtocol {
    func save(_ toolBoxTalk: [ToolBoxTalk]) throws
    func fetchAll() throws -> [ToolBoxTalk]
    func delete(id: Int) throws
}
