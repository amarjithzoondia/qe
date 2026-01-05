//
//  ObservationDBRepositoryProtocol.swift
//  ALNASR
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

protocol ObservationDBRepositoryProtocol {
    func save(_ observation: NFObservationDraftData) throws
    func fetchAll() throws -> [NFObservationDraftData]
    func delete(id: Int) throws
}
