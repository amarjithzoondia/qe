//
//  DashboardViewModel.swift
// QualityExpertise
//
//  Created by developer on 21/01/22.
//
import AdSupport
import AppTrackingTransparency
import Foundation
import GoogleMobileAds

class DashboardViewModel: ObservableObject {
    @Published var addTrackingAuthStatus: ATTrackingManager.AuthorizationStatus = .authorized
    
    func requestIDFA() {
        
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          DispatchQueue.main.async {
              self.addTrackingAuthStatus = status
          }
      })
    }
    
    func checkRole() {
        DashboardRequest.dashBoardFlag(params: .init(flowType: .oldFlow)).makeCall(responseType: DashboardResponse.self) { _ in
        } success: { response in
            UserManager.shared.notificationUnReadCount = response.notificationCount
            UserManager.shared.pendingActionsCount = response.pendingActionsCount
        } failure: { error in
            self.toast = error.toast
        }

    }
    
    var viewGoupText: String {
        "view_groups".localizedString()
    }
    
    var inviteGroupText: String {
        "invite_users_to_group_title".localizedString()
    }
    
    var resuestGroupText: String {
        "request_access_to_group".localizedString()
    }
    
    var createGroupText: String {
        "create_new_group".localizedString()
    }
    
    var viewObservationText: String {
        "view_observation".localizedString()
    }
    
    var observationDraftText: String {
        "view_drafts".localizedString()
    }
    
    var createObservationText: String {
        "create_observation".localizedString()
    }
    
    var toast: AlertToast = Toast.alert(title: "alert".localizedString(), subTitle: "login_required_message".localizedString())
}
