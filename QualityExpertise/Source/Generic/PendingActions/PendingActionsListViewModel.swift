//
//  PendingActionsListViewModel.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import Foundation
import AppTrackingTransparency
import AdSupport

class PendingActionsListViewModel: BaseViewModel, ObservableObject {
    @Published var pendingActions: [PendingActionDetails] = []
    @Published var addTrackingAuthStatus: ATTrackingManager.AuthorizationStatus = .authorized
    @Published var filterPendingActions: [PendingActionDetails] = []
    override func onRetry() {
        fetchPendingActionsList{completed in }
    }
    
    func fetchPendingActionsList(completion: @escaping (_ completed: Bool) -> ()) {
        PendingActionRequest
            .list
            .makeCall(responseType: PendingActionRequest.ListResponse.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (result) in
                self.pendingActions = result.pendingActions
                UserManager.shared.notificationUnReadCount = result.notificationUnReadCount
                UserManager.shared.pendingActionsCount = result.pendingActionsCount
                self.noDataFound = (self.pendingActions.count) <= 0
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }

    }
    
    func requestIDFA() {
        
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          DispatchQueue.main.async {
              self.addTrackingAuthStatus = status
          }
      })
    }
}
