//
//  GroupRequestRejectedPopUpViewModel.swift
// ALNASR
//
//  Created by developer on 17/03/22.
//

import Foundation

class GroupRequestRejectedPopUpViewModel: BaseViewModel, ObservableObject {
    @Published var groupDetail: GroupData?
    var notification: AppNotification
    
    internal init(notification: AppNotification) {
        self.notification = notification
    }
    
    func viewGroup() {
        let dataComponents = notification.groupCode?.components(separatedBy: "-")
        GroupRequest
            .viewGroup(params: .init(groupId: dataComponents?.last?.toInt , groupShortCode: dataComponents?.first ?? "", notificationId: notification.id))
            .makeCall(responseType: RequestAccessRequest.ViewGroupResponse.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                if let groupDetail = response.group {
                    self.groupDetail = groupDetail
                }
                UserManager.instance.notificationUnReadCount = response.notificationUnReadCount
                UserManager.instance.pendingActionsCount = response.pendingActionsCount
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}

