//
//  InspectionDBUseCase.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class InspectionDBUseCase {
    private let repository: InspectionDBRepositoryProtocol
    
    init(repository: InspectionDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveInspections(_ inspection: Inspections) throws {
        try repository.save(inspection)
    }
    
    func getInspections() throws -> [Inspections] {
        try repository.fetchAll()
    }
    
    func deleteInspection(_ inspection: Inspections) throws {
        try repository.delete(id: inspection.id)
    }
    
    func saveContents( contents: InspectionContentsResponse) throws {
        try repository.saveContents(contents)
    }
    
    func getContent(_ inspectionTypeId: Int) throws -> [EquipmentStatic]  {
        try repository.getContents(inspectionTypeId)
    }
    
    func getLatestUpdatedTime(_ inspectionTypeId: Int) throws -> String? {
        try repository.getLatestUpdatedTime(inspectionTypeId)
    }
    
    func getLatestUpdatedTime() throws -> Date? {
        try repository.getLatestUpdatedTime()
    }
    
    func saveAuditItems(_ auditItems: AuditsInspectionsListResponse) throws {
        try repository.saveAuditItems(auditItems)
    }
    
    func getAuditItems() throws -> [AuditsInspectionsList] {
        try repository.getAuditItems()
    }
    
    func getUpdatedAuditItemsDate() throws -> String? {
        try repository.getUpdatedAuditItemsDate()
    }
    
    
}
