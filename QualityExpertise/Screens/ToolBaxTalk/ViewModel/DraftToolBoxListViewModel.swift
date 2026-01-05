//
//  DraftToolBoxListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 11/09/25.
//

import Foundation

class DraftToolBoxListViewModel: BaseViewModel, ObservableObject {
    @Published var toolBoxTalks: [ToolBoxTalk] = []
    
    private let localRepository = ToolBoxTalkDBRepository()
    private let localUseCase: ToolBoxTalkDBUseCase
    
    override init() {
        localUseCase = ToolBoxTalkDBUseCase(repository: localRepository)
    }
    
    func fetchDraftList() {
        self.error = nil
        self.noDataFound = false
        do {
            let toolBoxTalks = try localUseCase.getToolBoxTalks()
            DispatchQueue.safeAsyncMain {
                self.toolBoxTalks = toolBoxTalks
                self.noDataFound = toolBoxTalks.isEmpty
            }
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
    
    func deleteViolation(toolBox: ToolBoxTalk) -> Bool {
        do {
            try localUseCase.deleteToolBoxTalk(toolBox)
            return true
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
            return false
        }
    }
}
