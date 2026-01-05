//
//  NFNotificationListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation

class NFNotificationListViewModel: BaseViewModel, ObservableObject {
    @Published var notifications = [AppNotification]()
    
    internal override init() {
        super.init()
        
        fetchNotificationList()
    }
    
    override func onRetry() {
        fetchNotificationList()
    }
    
    func fetchNotificationList() {
        NFNotificationRequest
            .list
            .makeCall(responseType: NotificationRequest.ListResponse.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                self.notifications = response.notifications
                UserManager.shared.notificationUnReadCount = response.notificationUnReadCount
                UserManager.shared.pendingActionsCount = response.pendingActionsCount
                self.noDataFound = self.notifications.count <= 0
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
