//
//  DashboardViewModel.swift
// ALNASR
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
    
    var viewGoupText: String {
        return "View" + Constants.NEXT_LINE + "Groups"
    }
    
    var inviteGroupText: String {
        return "Invite Users to" + Constants.NEXT_LINE + "Group"
    }
    
    var resuestGroupText: String {
        return "Request Access to" + Constants.NEXT_LINE + "Group"
    }
    
    var createGroupText: String {
        return "Create New" + Constants.NEXT_LINE + "Group"
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
