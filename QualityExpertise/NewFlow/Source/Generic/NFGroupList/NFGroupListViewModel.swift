//
//  NFGroupListViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation
import SwiftUI

class NFGroupListViewModel: ObservableObject {
    
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
    private let isFromViewGroup: Bool
    
    var groupsDetails = [GroupData]() {
        didSet {
            searchGroups = groupsDetails
        }
    }
    
    init(isFromViewGroup: Bool) {
        self.isFromViewGroup = isFromViewGroup
        fetchGroupList(isFromViewGroup: isFromViewGroup)
    }
    
    func onRefresh() {
        fetchGroupList(isFromViewGroup: isFromViewGroup)
    }
    
    func onRetry() {
        fetchGroupList(isFromViewGroup: isFromViewGroup)
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
    
    func fetchGroupList(searchKey: String? = "", isFromViewGroup: Bool) {
        
        NFGroupRequest
            .groupList(params: .init(searchKey: searchKey ?? "", isProjectList: isFromViewGroup))
            .makeCall(responseType: GroupListRequest.Response.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                DispatchQueue.main.async {
                    self.groupsDetails = response.groups.sorted {
                        $0.groupName
                            .localizedCaseInsensitiveCompare($1.groupName) == .orderedAscending
                    }
                    self.noDataFound = self.searchGroups.count <= 0
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
