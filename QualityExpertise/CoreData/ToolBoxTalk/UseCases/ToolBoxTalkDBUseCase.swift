//
//  ToolBoxTalkDBUseCase.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class ToolBoxTalkDBUseCase {
    private let repository: ToolBoxTalkDBRepositoryProtocol
    
    init(repository: ToolBoxTalkDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveToolBoxTalks(_ toolBoxTalk: [ToolBoxTalk]) throws {
        try repository.save(toolBoxTalk)
    }
    
    func getToolBoxTalks() throws -> [ToolBoxTalk] {
        try repository.fetchAll()
    }
    
    func deleteToolBoxTalk(_ toolBoxTalk: ToolBoxTalk) throws {
        try repository.delete(id: toolBoxTalk.id)
    }
}
