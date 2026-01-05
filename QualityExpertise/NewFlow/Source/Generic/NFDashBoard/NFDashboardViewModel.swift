//
//  NFDashboardViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import AdSupport
import AppTrackingTransparency
import Foundation
import GoogleMobileAds

class NFDashboardViewModel: ObservableObject {
    @Published var pendingActionsCount: Int = 0
    @Published var addTrackingAuthStatus: ATTrackingManager.AuthorizationStatus = .authorized
    @Published var isGroupAdmin: Bool = false
    func requestIDFA() {
        
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          DispatchQueue.main.async {
              self.addTrackingAuthStatus = status
          }
      })
    }
    
    func checkRole() {
        DashboardRequest.dashBoardFlag(params: .init(flowType: .newFlow)).makeCall(responseType: DashboardResponse.self) { _ in
        } success: { response in
            self.isGroupAdmin = response.isGroupAdmin ?? false
            UserManager.shared.notificationUnReadCount = response.notificationCount
            UserManager.shared.pendingActionsCount = response.pendingActionsCount
        } failure: { error in
            self.toast = error.toast
        }

    }
    
    var viewGoupText: String {
        return "View" + Constants.NEXT_LINE + "Project"
    }
    
    var inviteGroupText: String {
        return "Invite Users to" + Constants.NEXT_LINE + "Project"
    }
    
    var resuestGroupText: String {
        return "Request Access to" + Constants.NEXT_LINE + "Project"
    }
    
    var createGroupText: String {
        return "Create New" + Constants.NEXT_LINE + "Project"
    }
    
    var viewObservationText: String {
        return "View" + Constants.NEXT_LINE + "Observation"
    }
    
    var observationDraftText: String {
        return "View" + Constants.NEXT_LINE + "Drafts"
    }
    
    var createObservationText: String {
        return "Create" + Constants.NEXT_LINE + "Observation"
    }
    
    var toast: AlertToast = Toast.alert(title: "Alert!", subTitle: "This feature requires you to Login")
}
