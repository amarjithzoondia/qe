//
//  IncidentDBRepositoryProtocol.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

protocol IncidentDBRepositoryProtocol {
    func save(_ incidents: [Incident]) throws
    func fetchAll() throws -> [Incident]
    func delete(id: Int) throws
}
