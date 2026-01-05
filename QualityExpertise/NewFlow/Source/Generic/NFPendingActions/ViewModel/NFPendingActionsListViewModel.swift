//
//  NFPendingActionsListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation
import AppTrackingTransparency
import AdSupport

class NFPendingActionsListViewModel: BaseViewModel, ObservableObject {
    @Published var pendingActions: [NFPendingActionDetails] = []
    @Published var addTrackingAuthStatus: ATTrackingManager.AuthorizationStatus = .authorized
    @Published var filterPendingActions: [NFPendingActionDetails] = []
    override func onRetry() {
        fetchPendingActionsList{completed in }
    }
    
    func fetchPendingActionsList(completion: @escaping (_ completed: Bool) -> ()) {
        NFPendingActionRequest
            .list
            .makeCall(responseType: NFPendingActionRequest.ListResponse.self) { (isLoading) in
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
