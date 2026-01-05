//
//  DraftViolationListViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//


import Foundation

class DraftViolationListViewModel: BaseViewModel, ObservableObject {
    @Published var violations: [Violation] = []
    
    private let localRepository = ViolationDBRepository()
    private let localUseCase: ViolationDBUseCase
    
    override init() {
        localUseCase = ViolationDBUseCase(repository: localRepository)
    }
    
    func fetchDraftList() {
        self.error = nil
        self.noDataFound = false
        do {
            let violations = try localUseCase.getViolations()
            DispatchQueue.safeAsyncMain {
                self.violations = violations
                violations.forEach { vio in
                    print("vio.violationDate", vio.violationDate)
                }
                self.noDataFound = violations.isEmpty
            }
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
    
    func deleteViolation(violation: Violation) -> Bool {
        do {
            try localUseCase.deleteViolation(violation)
            return true
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
            return false
        }
    }
}
