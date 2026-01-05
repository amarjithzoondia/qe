//
//  NFFilterObservationViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation

class NFFilterObservationViewModel: BaseViewModel, ObservableObject {
    @Published var searchGroups = [GroupData]()
    @Published var searchObserversUsersList = [UserData]()
    @Published var searchresponsiblePersonsList = [UserData]()
    @Published var selecteditem: FilterType = .group
    
    var groupsDetails = [GroupData]() {
        didSet {
            searchGroups = groupsDetails
        }
    }
    
    var observersList = [UserData]() {
        didSet {
            searchObserversUsersList = observersList
        }
    }
    
    var responsiblePersonsList = [UserData]() {
        didSet {
            searchresponsiblePersonsList = responsiblePersonsList
        }
    }
    
    var selectedGroupsIds: [Int]? {
        get {
            searchGroups
                .filter { $0.isSelected ?? false }
                .compactMap { Int($0.groupId) }
        }
        set {
            guard let newValue = newValue else {
                // Clear all selections if nil
                searchGroups.indices.forEach { i in
                    searchGroups[i].isSelected = false
                }
                return
            }

            // Mark selected groups based on given IDs
            searchGroups.indices.forEach { i in
                if let gid = Int(searchGroups[i].groupId) {
                    searchGroups[i].isSelected = newValue.contains(gid)
                } else {
                    searchGroups[i].isSelected = false
                }
            }
        }
    }

    var selectedObserversIds: [Int]? {
        get {
            searchObserversUsersList
                .filter { $0.isSelected ?? false }
                .map { $0.userId }
        }
        set {
            guard let newValue = newValue else {
                searchObserversUsersList.indices.forEach { i in
                    searchObserversUsersList[i].isSelected = false
                }
                return
            }

            searchObserversUsersList.indices.forEach { i in
                searchObserversUsersList[i].isSelected = newValue.contains(searchObserversUsersList[i].userId)
            }
        }
    }

    var selectedResponsiblePersonsIds: [Int]? {
        get {
            searchresponsiblePersonsList
                .filter { $0.isSelected ?? false }
                .map { $0.userId }
        }
        set {
            guard let newValue = newValue else {
                searchresponsiblePersonsList.indices.forEach { i in
                    searchresponsiblePersonsList[i].isSelected = false
                }
                return
            }

            searchresponsiblePersonsList.indices.forEach { i in
                searchresponsiblePersonsList[i].isSelected = newValue.contains(searchresponsiblePersonsList[i].userId)
            }
        }
    }

    
    override func onRetry() {
        
    }
    
    func search(key: String, selectedItem: FilterType) {
        if selectedItem == .group {
            var result = key.isEmpty ? groupsDetails : groupsDetails.filter({ $0.groupName.lowercased().contains(key.lowercased()) })
            let alreadySelected = groupsDetails.filter({ $0.isSelected ?? false })
            for (index, item) in result.enumerated() {
                if alreadySelected.contains(item) {
                    result[index].isSelected = true
                }
            }
            searchGroups = result
        } else if selectedItem == .observer {
            var result = key.isEmpty ? observersList : observersList.filter({ $0.name.lowercased().contains(key.lowercased()) })
            let alreadySelected = observersList.filter({ $0.isSelected ?? false })
            for (index, item) in result.enumerated() {
                if alreadySelected.contains(item) {
                    result[index].isSelected = true
                }
            }
            searchObserversUsersList = result
        } else if selectedItem == .responsible {
            var result = key.isEmpty ? responsiblePersonsList : responsiblePersonsList.filter({ $0.name.lowercased().contains(key.lowercased()) })
            let alreadySelected = responsiblePersonsList.filter({ $0.isSelected ?? false })
            for (index, item) in result.enumerated() {
                if alreadySelected.contains(item) {
                    result[index].isSelected = true
                }
            }
            searchresponsiblePersonsList = result
        }
    }
    
    func resetSearch(for selectedItem: NFFilterType) {
        switch selectedItem {
        case .project:
            searchGroups = groupsDetails
        case .observer:
            searchObserversUsersList = observersList
        case .responsible:
            searchresponsiblePersonsList = responsiblePersonsList
        case .status:
            return
        case .date:
            return
        }
    }


    func registerGroup(groupData: GroupData, isSelected: Bool) {
        if let index = searchGroups.firstIndex(where: { $0 == groupData }) {
            searchGroups[index].isSelected = isSelected
        }
    }
    
    func registerUser(userData: UserData, isSelected: Bool, selectedItem: FilterType) {
        if selectedItem == .observer {
            if let index = searchObserversUsersList.firstIndex(where: { $0 == userData }) {
                searchObserversUsersList[index].isSelected = isSelected
            }
        } else if selectedItem == .responsible {
            if let index = searchresponsiblePersonsList.firstIndex(where: { $0 == userData}) {
                searchresponsiblePersonsList[index].isSelected = isSelected
            }
        }
    }
    
    func fetchGroupList(searchKey: String? = "", selectedIds: [Int]? = nil) {
        NFGroupRequest
            .groupList(params: .init(searchKey: searchKey ?? "", isProjectList: true))
            .makeCall(responseType: GroupListRequest.Response.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                DispatchQueue.main.async {
                    self.groupsDetails = response.groups
                    if let selectedIds = selectedIds {
                        for id in selectedIds {
                            if let index = self.searchGroups.firstIndex(where: { $0.groupId.toInt == id }) {
                                self.searchGroups[index].isSelected = true
                            }
                        }
                    }
                    
                    self.noDataFound = self.searchGroups.count <= 0
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func fetchUsersList(selectedIds: [Int]? = nil,selecedItem: FilterType) {
        UserRequest
            .userList(params: .init(searchKey: ""))
            .makeCall(responseType: UserListForGroupRequest.Response.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                DispatchQueue.main.async {
                    if selecedItem == .observer {
                        self.observersList = response.users
                        if let selectedIds = selectedIds {
                            for id in selectedIds {
                                if let index = self.searchObserversUsersList.firstIndex(where: { $0.userId == id }) {
                                    self.searchObserversUsersList[index].isSelected = true
                                }
                            }
                        }
                        self.noDataFound = self.searchObserversUsersList.count <= 0
                    } else if selecedItem == .responsible {
                        self.responsiblePersonsList = response.users
                        if let selectedIds = selectedIds {
                            for id in selectedIds {
                                if let index = self.searchresponsiblePersonsList.firstIndex(where: { $0.userId == id }) {
                                    self.searchresponsiblePersonsList[index].isSelected = true
                                }
                            }
                        }
                        self.noDataFound = self.searchresponsiblePersonsList.count <= 0
                    }
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    
    func fetchProjectAndUsersList(selectedGroupIds: [Int]? = nil, selectedResponsibleIds: [Int]? = nil, selectedObserversIds: [Int]? = nil) {
        FilterRequest.getContents.makeCall(responseType: FilterResponse.self) { isLoading in
            DispatchQueue.main.async {
                self.isLoading = isLoading
            }
        } success: { result in
            DispatchQueue.main.async {
                // Assign main data
                self.groupsDetails = result.projects
                self.responsiblePersonsList = result.responsiblePersons
                self.observersList = result.responsiblePersons

                // Keep filtered search data in sync
                self.searchGroups = self.groupsDetails
                self.searchresponsiblePersonsList = self.responsiblePersonsList
                self.searchObserversUsersList = self.responsiblePersonsList

                // Apply previously selected IDs if any
                if let selectedGroupIds = selectedGroupIds {
                    self.selectedGroupsIds = selectedGroupIds
                }
                if let selectedResponsibleIds = selectedResponsibleIds {
                    self.selectedResponsiblePersonsIds = selectedResponsibleIds
                }
                if let selectedObserversIds = selectedObserversIds {
                    self.selectedObserversIds = selectedObserversIds
                }

                // Handle empty state
                self.noDataFound = self.searchGroups.isEmpty && self.searchresponsiblePersonsList.isEmpty && self.searchObserversUsersList.isEmpty

                // Reset error if everything loaded fine
                self.error = nil
            }
        } failure: { error in
            DispatchQueue.main.async {
                self.error = error
                self.toast = error.toast
                self.isLoading = false
                self.noDataFound = true
            }
        }
    }

}
