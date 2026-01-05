//
//  AuditInspectionsViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

import UIKit

class AuditInspectionsViewModel: BaseViewModel, ObservableObject {
    @Published var inspectionsList: [AuditsInspectionsList] = []
    private let localDBRepository = InspectionDBRepository()
    private let localDBUseCase: InspectionDBUseCase
    
    override init() {
        self.localDBUseCase = InspectionDBUseCase(repository: localDBRepository)

    }
    
    func fetchList() {
        isConnectedToInternet() ? fetchFromAPI() : fetchFromLocalDB()
    }
    
    func fetchFromAPI() {
        self.isLoading = true
        InspectionsRequest.auditItems(params: .init(updatedTime: nil)).makeCall(responseType: AuditsInspectionsListResponse.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.main.async {
                self.inspectionsList = response.contents.sorted {
                    ($0.auditItemTitle)
                        .localizedCaseInsensitiveCompare($1.auditItemTitle) == .orderedAscending
                }
                self.noDataFound = self.inspectionsList.isEmpty
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.inspectionsList = []
                self.error = error
                self.toast = error.toast
            }
        }
    }
    
    func fetchFromLocalDB() {
        do {
            let items = try localDBUseCase.getAuditItems()
            DispatchQueue.main.async {
                self.inspectionsList = items
                self.noDataFound = self.inspectionsList.isEmpty
            }
        } catch {
            DispatchQueue.main.async {
                self.inspectionsList = []
                self.error = error as? SystemError
                self.toast = error.toast
            }
        }
        
    }
    
    private func isConnectedToInternet() -> Bool {
        RepositoryManager.Connectivity.isConnected
    }
}
