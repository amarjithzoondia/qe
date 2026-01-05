//
//  ToolBoxTalkDBUseCase.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class ToolBoxTalkDBUseCase {
    private let repository: IncidentDBRepositoryProtocol
    
    init(repository: IncidentDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveIncidents(_ incident: [Incident]) throws {
        try repository.save(incident)
    }
    
    func getIncidents() throws -> [Incident] {
        try repository.fetchAll()
    }
    
    func deleteIncidents(_ incident: Incident) throws {
        try repository.delete(id: incident.id)
    }
}
