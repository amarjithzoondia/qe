//
//  ViolationUseCase.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class ViolationDBUseCase {
    private let repository: ViolationDBRepositoryProtocol
    
    init(repository: ViolationDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveViolations(_ violations: [Violation]) throws {
        try repository.save(violations)
    }
    
    func getViolations() throws -> [Violation] {
        try repository.fetchAll()
    }
    
    func deleteViolation(_ violation: Violation) throws {
        try repository.delete(id: violation.id)
    }
}
