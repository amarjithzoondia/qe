//
//  GroupListViewModel.swift
// QualityExpertise
//
//  Created by developer on 28/01/22.
//

import Foundation
import SwiftUI

class GroupListViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var noDataFound = false
    @Published var error: SystemError?
    @Published var showToast = false
    @Published var searchGroups = [GroupData]()
    var groupId: String = Constants.EMPTY_STRING
    var groupCode: String = Constants.EMPTY_STRING
    var groupData: GroupData?
    var toast: AlertToast = Toast.alert(subTitle: "") {
        didSet {
            showToast = true
        }
    }
    
    var groupsDetails = [GroupData]() {
        didSet {
            searchGroups = groupsDetails
        }
    }
    
    init() {
        
        fetchGroupList()
    }
    
    func onRefresh() {
        fetchGroupList()
    }
    
    func onRetry() {
        
        fetchGroupList()
    }
    
    func search(key: String) {
        let result = key.isEmpty ? groupsDetails : groupsDetails.filter({ $0.groupName.lowercased().contains(key.lowercased()) })
        searchGroups = result
    }
    
    func register(groupDetail: GroupData, isSelected: Bool) {
        if let index = searchGroups.firstIndex(where: { $0 == groupDetail }) {
            searchGroups[index].isSelected = isSelected
            self.groupId = searchGroups[index].groupId
            self.groupCode = searchGroups[index].groupCode
            self.groupData = searchGroups[index]
        }
        
        for index in (0 ..< searchGroups.count) where searchGroups[index] != groupDetail {
            searchGroups[index].isSelected = false
        }
    }
    
    func fetchGroupList(searchKey: String? = "") {
        GroupRequest
            .groupList(params: .init(searchKey: searchKey ?? ""))
            .makeCall(responseType: GroupListRequest.Response.self) { (isLoading) in
                DispatchQueue.main.async { 
                    self.isLoading = isLoading
                }
            } success: { (response) in
                DispatchQueue.main.async {
                    self.groupsDetails = response.groups
                    self.noDataFound = self.searchGroups.count <= 0
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
