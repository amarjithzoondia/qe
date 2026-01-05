//
//  UserListViewModel.swift
// QualityExpertise
//
//  Created by developer on 08/02/22.
//

import Foundation
import SwiftUI

class UserListViewModel: BaseViewModel, ObservableObject {
    @Published var searchUsersList = [UserData]()
    var groupData: GroupData?
    var userData: UserData?
    
    var usersList = [UserData]() {
        didSet {
            searchUsersList = usersList
        }
    }
    
    var selectedUsers: [UserData]? {
        searchUsersList.filter({ ($0.isSelected ?? false) }).map({ $0 })
    }

    internal init(groupData: GroupData) {
        super.init()
        
        self.groupData = groupData
    }
    
    override func onRefresh() {
        fetchList()
    }
    
    override func onRetry() {
        super.onRetry()
        
        fetchList()
    }
    
    func register(userData: UserData, isSelected: Bool, isFromSelectuser: Bool) {
        if let index = searchUsersList.firstIndex(where: { $0 == userData }) {
            searchUsersList[index].isSelected = isSelected
            if isFromSelectuser {
                self.userData = searchUsersList[index]
                for index in (0 ..< searchUsersList.count) where searchUsersList[index] != userData {
                    searchUsersList[index].isSelected = false
                }
            }
        }
    }
    
    func search(key: String) {
        let result = key.isEmpty ? usersList : usersList.filter({ $0.name.lowercased().contains(key.lowercased()) })
        searchUsersList = result
    }
    
    func fetchList(selectedUserId: Int? = nil, isFromSelectAUser: Bool? = nil, selectedUserIds: [Int]? = nil) {
        GroupRequest
            .userList(params: .init(groupId: groupData?.groupId.toInt ?? -1, searchKey: "", groupCode: groupData?.groupCode ?? ""))
            .makeCall(responseType: UserListRequest.Response.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                DispatchQueue.main.async {
                    self.usersList = response.users
                    if isFromSelectAUser ?? false {
                        if selectedUserId != nil {
                            if let index = self.searchUsersList.firstIndex(where: { $0.userId == selectedUserId }) {
                                self.searchUsersList[index].isSelected = true
                            }
                        }
                    } else {
                        if let selectedIds = selectedUserIds {
                            for id in selectedIds {
                                if let index = self.searchUsersList.firstIndex(where: { $0.userId == id }) {
                                    self.searchUsersList[index].isSelected = true
                                }
                            }
                        }
                    }
                    self.noDataFound = self.searchUsersList.count <= 0
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
}
