//
//  RequestAccessViewModel.swift
// QualityExpertise
//
//  Created by developer on 30/01/22.
//

import Foundation

class RequestAccessViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var error: SystemError?
    @Published var showToast = false
    @Published var groupDetail: GroupData?
    @Published var statusMessage: String?
    @Published var isGroupVerified: Bool = false
    
    var toast: AlertToast = Toast.alert(subTitle: "") {
        didSet {
            showToast = true
        }
    }
    
    func viewGroup(groupId: String, groupShortCode: String, notificationId: Int, completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let groupCode = try groupShortCode.validatedText(validationType: .requiredField(field: "group_code".localizedString()))
            
            GroupRequest
                .viewGroup(params: .init(groupId: groupId.toInt, groupShortCode: groupCode, notificationId: notificationId))
                .makeCall(responseType: RequestAccessRequest.ViewGroupResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    if let groupDetail = response.group {
                        self.groupDetail = groupDetail
                    }
                    self.isGroupVerified = response.groupVerified
                    UserManager.shared.notificationUnReadCount = response.notificationUnReadCount
                    UserManager.shared.pendingActionsCount = response.pendingActionsCount
                    completion(true)
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
    
    func requestToGroup(groupId: String, groupShortCode: String,completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let groupId = try groupId.validatedText(validationType: .requiredField(field: "group_id".localizedString()))
            let groupCode = try groupShortCode.validatedText(validationType: .requiredField(field: "group_code".localizedString()))
            
            GroupRequest
                .requestToGroup(params: .init(groupId: groupId.toInt, groupShortCode: groupCode))
                .makeCall(responseType: RequestAccessRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.isGroupVerified = response.groupVerified
                    completion(true)
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
            
        } catch {
            toast = (error as! SystemError).toast
        }
    }
}
