//
//  DraftInspectionsListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 01/08/25.
//

import Foundation

class DraftInspectionsListViewModel: BaseViewModel, ObservableObject {
    @Published var inspections: [Inspections] = []
    
    private let localRepository = InspectionDBRepository()
    private let localUseCase: InspectionDBUseCase
    
    override init() {
        localUseCase = InspectionDBUseCase(repository: localRepository)
    }
    
    func fetchDraftList() {
        self.error = nil
        self.noDataFound = false
        do {
            let inspections = try localUseCase.getInspections()
            DispatchQueue.safeAsyncMain {
                self.inspections = inspections
                self.noDataFound = inspections.isEmpty
            }
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
    
    func deleteViolation(inspection: Inspections) -> Bool {
        do {
            try localUseCase.deleteInspection(inspection)
            return true
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
            return false
        }
    }
}
