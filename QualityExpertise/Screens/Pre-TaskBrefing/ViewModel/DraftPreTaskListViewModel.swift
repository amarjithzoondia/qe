//
//  DraftPreTaskListViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 27/10/25.
//


import Foundation

class DraftPreTaskListViewModel: BaseViewModel, ObservableObject {
    @Published var preTasks: [PreTask] = []
    
    private let localRepository = PreTaskDBRepository()
    private let localUseCase: PreTaskDBUseCase
    
    override init() {
        localUseCase = PreTaskDBUseCase(repository: localRepository)
    }
    
    func fetchDraftList() {
        self.error = nil
        self.noDataFound = false
        do {
            let preTasks = try localUseCase.getPreTasks()
            DispatchQueue.safeAsyncMain {
                self.preTasks = preTasks
                self.noDataFound = preTasks.isEmpty
            }
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
    
    func deletePreTask(preTask: PreTask) -> Bool {
        do {
            try localUseCase.deletePreTask(preTask)
            return true
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
            return false
        }
    }
}
