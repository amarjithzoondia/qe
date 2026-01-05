//
//  DraftIncidentListViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 11/09/25.
//

import Foundation

class DraftIncidentListViewModel: BaseViewModel, ObservableObject {
    @Published var incidents: [Incident] = []
    
    private let localRepository = IncidentDBRepository()
    private let localUseCase: IncidentDBUseCase
    
    override init() {
        localUseCase = IncidentDBUseCase(repository: localRepository)
    }
    
    func fetchDraftList() {
        self.error = nil
        self.noDataFound = false
        do {
            let incidents = try localUseCase.getIncidents()
            DispatchQueue.safeAsyncMain {
                self.incidents = incidents
                self.noDataFound = incidents.isEmpty
            }
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
    
    func deleteViolation(incident: Incident) -> Bool {
        do {
            try localUseCase.deleteIncidents(incident)
            return true
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
            return false
        }
    }
}
