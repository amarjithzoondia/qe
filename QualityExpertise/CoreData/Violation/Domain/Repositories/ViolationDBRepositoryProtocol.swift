//
//  ViolationRepositoryProtocol.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

protocol ViolationDBRepositoryProtocol {
    func save(_ violations: [Violation]) throws
    func fetchAll() throws -> [Violation]
    func delete(id: Int) throws
}
