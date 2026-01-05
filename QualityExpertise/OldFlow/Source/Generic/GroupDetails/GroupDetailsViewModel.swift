//
//  GroupDetailsViewModel.swift
// ALNASR
//
//  Created by developer on 21/02/22.
//

import Foundation

class GroupDetailsViewModel: BaseViewModel, ObservableObject {
    @Published var groupDetails: GroupDetails?
    @Published var searchGroupMembers = [GroupMemberDetails]()
    @Published var groupData = GroupData.dummy()
    @Published var isSuccess: Bool = false
    @Published var statusMessage:String = Constants.EMPTY_STRING
    
    var groupId: String = Constants.EMPTY_STRING
    var groupCode: String = Constants.EMPTY_STRING
    var notificationId: Int?
    
    var goupCode: String {
        return ("ID: " + (groupDetails?.groupCode ?? ""))
    }
    
    var groupMemberDetails = [GroupMemberDetails]() {
        didSet {
            searchGroupMembers = groupMemberDetails
        }
    }
    
    internal init(groupId: String, groupCode: String, notificationId: Int? = nil) {
        super.init()
        
        self.groupId = groupId
        self.groupCode = groupCode
        self.notificationId = notificationId
        getGroupDetails()
    }
    
    override func onRefresh() {
        getGroupDetails()
    }
    
    override func onRetry() {
        
        getGroupDetails()
    }
    
    func search(key: String) {
        let result = key.isEmpty ? groupMemberDetails : groupMemberDetails.filter({ $0.name.lowercased().contains(key.lowercased()) })
        searchGroupMembers = result
    }
    
    func getGroupDetails() {
        GroupRequest
            .details(params: .init(notificationId: notificationId ?? -1, groupId: groupId.toInt ?? -1, groupCode: groupCode))
            .makeCall(responseType: GroupDetails.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                self.groupDetails = response
                self.groupData.groupId = response.groupId
                self.groupData.groupCode = response.groupCode
                self.groupData.groupName = response.groupName
                self.groupData.groupImage = response.groupImage
                self.groupData.description = response.description
                self.groupData.userRole = response.userRole
                if let members = self.groupDetails?.members {
                    self.groupMemberDetails = members
                }
                UserManager.instance.notificationUnReadCount = response.notificationUnReadCount
                UserManager.instance.pendingActionsCount = response.pendingActionsCount
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func removeMemberFromGroup(userId: Int, completion: @escaping (_ completed: Bool) -> ()) {
        GroupRequest
            .deleteMemberFromGroup(params: .init(groupId: groupDetails?.groupId.toInt ?? -1, groupCode: (groupDetails?.groupCode ?? ""), userId: userId))
            .makeCall(responseType: GroupDetailRequest.DeleteUserFromListResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func changeUserRole(userId: Int, newUserRole: UserRole, completion: @escaping (_ completed: Bool) -> ()) {
        GroupRequest
            .changeUserRole(params: .init(groupId: groupDetails?.groupId.toInt ?? -1, groupCode: groupDetails?.groupCode ?? "", userId: userId, newRole: newUserRole))
            .makeCall(responseType: GroupDetailRequest.DeleteUserFromListResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func handOverSuperAdminRights(handOverTo: Int, password: String, completion: @escaping (_ completed: Bool) -> ()) {
        GroupRequest
            .handOverSuperAdminRights(params: .init(groupId: groupDetails?.groupId.toInt ?? -1, groupCode: groupDetails?.groupCode ?? "", password: password, handOverTo: handOverTo))
            .makeCall(responseType: GroupDetailRequest.CommonStatusResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                self.isSuccess = response.isSuccess
                self.statusMessage = response.statusMessage
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func deleteGroup(password: String, completion: @escaping (_ completed: Bool) -> ()) {
        GroupRequest
            .deleteGroup(params: .init(groupId: groupDetails?.groupId.toInt ?? -1, groupCode: groupDetails?.groupCode ?? "", password: password))
            .makeCall(responseType: GroupDetailRequest.CommonStatusResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                self.isSuccess = response.isSuccess
                self.statusMessage = response.statusMessage
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func exitGroup(completion: @escaping (_ completed: Bool) -> ()) {
        GroupRequest
            .exitGroup(params: .init(groupCode: groupDetails?.groupCode ?? ""))
            .makeCall(responseType: GroupDetailRequest.ExitGroupResponse.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                completion(true)
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
