//
//  NotificationListViewModel.swift
// ALNASR
//
//  Created by developer on 07/03/22.
//

import Foundation

class NotificationListViewModel: BaseViewModel, ObservableObject {
    @Published var notifications = [AppNotification]()
    
    internal override init() {
        super.init()
        
        fetchNotificationList()
    }
    
    override func onRetry() {
        fetchNotificationList()
    }
    
    func fetchNotificationList() {
        NotificationRequest
            .list
            .makeCall(responseType: NotificationRequest.ListResponse.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                self.notifications = response.notifications
                UserManager.instance.notificationUnReadCount = response.notificationUnReadCount
                UserManager.instance.pendingActionsCount = response.pendingActionsCount
                self.noDataFound = self.notifications.count <= 0
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
