//
//  InviteUserViewModel.swift
// QualityExpertise
//
//  Created by developer on 27/01/22.
//

import SwiftUI
import Foundation

class InviteUserViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var showToast: Bool = false
    var groupData: GroupData?
    
    func inviteUser(userEmailList: [String], completion: @escaping (_ completed: Bool) -> ()) {
        
        GroupRequest
            .inviteGroup(params: .init(groupId: groupData?.groupId.toInt ?? -1, groupCode: groupData?.groupCode ?? "", usersEmails: userEmailList))
            .makeCall(responseType: InviteGroupRequest.Response.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                completion(true)
                NotificationCenter.default.post(name: .UPDATE_GROUP,
                                                object: nil)
            } failure: { (error) in
                self.toast = error.toast
            }
    }
    
    init(groupData: GroupData) {
        self.groupData = groupData
    }
    
    var toast: AlertToast = Toast.alert(subTitle: "given_email_already_in_list".localizedString()) {
        didSet {
            showToast = true
        }
    }
}
