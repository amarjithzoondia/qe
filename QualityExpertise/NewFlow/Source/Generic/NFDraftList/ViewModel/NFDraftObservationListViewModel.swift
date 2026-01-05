//
//  NFDraftObservationListViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation

class NFDraftObservationListViewModel: BaseViewModel, ObservableObject {
    @Published var observations: [NFObservationDraftData] = []
    private let localDBRepository = ObservationDBRepository()
    private let localDBUseCase: ObservationDBUseCase
    
    override init() {
        localDBUseCase = ObservationDBUseCase(repository: localDBRepository)
    }
    
    func fetchDraftList() {
        self.error = nil
        self.noDataFound = false
        do {
            let observations = try localDBUseCase.getObservations()
            DispatchQueue.safeAsyncMain {
                self.observations = observations
                self.noDataFound = observations.isEmpty
            }
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
    
    func deleteObservation(observationId: Int, completion: @escaping(Bool) -> ()) {
        do {
            try localDBUseCase.deleteObservation(observationId)
            completion(true)
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
}

