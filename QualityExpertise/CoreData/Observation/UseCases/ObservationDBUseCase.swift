//
//  ObservationDBUseCase.swift
//  ALNASR
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class ObservationDBUseCase {
    private let repository: ObservationDBRepositoryProtocol
    
    init(repository: ObservationDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveObservation(_ observation: NFObservationDraftData) throws {
        try repository.save(observation)
    }
    
    func getObservations() throws -> [NFObservationDraftData] {
        try repository.fetchAll()
    }
    
    func deleteObservation(_ observationID: Int) throws {
        try repository.delete(id: observationID)
    }
}
