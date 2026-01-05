//
//  InspectionDBRepositoryProtocol.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

protocol InspectionDBRepositoryProtocol {
    func save(_ inspection: Inspections) throws
    func fetchAll() throws -> [Inspections]
    func delete(id: Int) throws
    func getAllAnswers(inspectionId: Int) throws -> [EquipmentStatic]
    func saveContents(_ contents: InspectionContentsResponse) throws
    func getContents(_ inspectionTypeId: Int) throws -> [EquipmentStatic]
    func getLatestUpdatedTime() throws -> Date?
    func getLatestUpdatedTime(_ inspectionTypeId: Int) throws -> String?
    func saveAuditItems(_ auditItems: AuditsInspectionsListResponse) throws
    func getAuditItems() throws -> [AuditsInspectionsList]
    func getUpdatedAuditItemsDate() throws -> String?
}
