//
//  Untitled.swift
//  ALNASR
//
//  Created by Amarjith B on 14/10/25.
//

import Foundation

class FilterSectionViewModel: BaseViewModel, ObservableObject {
    @Published var searchProjects = [GroupData]()
    @Published var searchObserversUsersList = [UserData]()
    @Published var searchresponsiblePersonsList = [UserData]()
    @Published var selecteditem: FilterTab = .projects

    var groupsDetails = [GroupData]() {
        didSet {
            searchProjects = groupsDetails
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
            searchProjects
                .filter { $0.isSelected ?? false }
                .compactMap { Int($0.groupId) }
        }
        set {
            guard let newValue = newValue else {
                // Clear all selections if nil
                searchProjects.indices.forEach { i in
                    searchProjects[i].isSelected = false
                }
                return
            }

            // Mark selected groups based on given IDs
            searchProjects.indices.forEach { i in
                if let gid = Int(searchProjects[i].groupId) {
                    searchProjects[i].isSelected = newValue.contains(gid)
                } else {
                    searchProjects[i].isSelected = false
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
        switch selectedItem {
        case .group:
            var result = key.isEmpty ? groupsDetails : groupsDetails.filter { $0.groupName.lowercased().contains(key.lowercased()) }
            let alreadySelected = groupsDetails.filter { $0.isSelected ?? false }
            syncGroupSelection(source: &result, selected: alreadySelected)
            searchProjects = result

        case .observer:
            // If observer == responsible, search in responsiblePersonsList
            let baseList = observersList.isEmpty ? responsiblePersonsList : observersList
            var result = key.isEmpty ? baseList : baseList.filter { $0.name.lowercased().contains(key.lowercased()) }
            let alreadySelected = baseList.filter { $0.isSelected ?? false }
            syncSelection(source: &result, selected: alreadySelected)
            searchObserversUsersList = result

        case .responsible:
            var result = key.isEmpty ? responsiblePersonsList : responsiblePersonsList.filter { $0.name.lowercased().contains(key.lowercased()) }
            let alreadySelected = responsiblePersonsList.filter { $0.isSelected ?? false }
            syncSelection(source: &result, selected: alreadySelected)
            searchresponsiblePersonsList = result
        case .status:
            return
        case .date:
            return
        }
    }

    // Helper
    private func syncSelection(source: inout [UserData], selected: [UserData]) {
        for (index, item) in source.enumerated() {
            if selected.contains(where: { $0 == item }) {
                source[index].isSelected = true
            }
        }
    }
    
    private func syncGroupSelection(source: inout [GroupData], selected: [GroupData]) {
        for (index, item) in source.enumerated() {
            if selected.contains(where: { $0 == item }) {
                source[index].isSelected = true
            }
        }
    }
    
    func resetSearch(for tab: FilterTab) {
        switch tab {
        case .projects:
            searchProjects = groupsDetails
        case .reportedBy:
            searchObserversUsersList = responsiblePersonsList
        case .incidentType:
            break
        case .date:
            break
        }
    }



    func registerGroup(groupData: GroupData, isSelected: Bool) {
        if let index = searchProjects.firstIndex(where: { $0 == groupData }) {
            searchProjects[index].isSelected = isSelected
        } else if let globalIndex = groupsDetails.firstIndex(where: { $0 == groupData }) {
            groupsDetails[globalIndex].isSelected = isSelected
            // keep searchProjects in sync
            if let idx = searchProjects.firstIndex(where: { $0 == groupData }) {
                searchProjects[idx].isSelected = isSelected
            }
        }
    }
    
    func deRegisterGroup() {
        for index in searchProjects.indices {
            searchProjects[index].isSelected = false
        }
        for index in groupsDetails.indices {
            groupsDetails[index].isSelected = false
        }
    }


    func registerUser(userData: UserData, isSelected: Bool, selectedItem: FilterType) {
        if selectedItem == .observer {
            if let index = searchObserversUsersList.firstIndex(where: { $0 == userData }) {
                searchObserversUsersList[index].isSelected = isSelected
            }
            if let idx = observersList.firstIndex(where: { $0 == userData }) {
                observersList[idx].isSelected = isSelected
            }
        } else if selectedItem == .responsible {
            if let index = searchresponsiblePersonsList.firstIndex(where: { $0 == userData}) {
                searchresponsiblePersonsList[index].isSelected = isSelected
            }
            if let idx = responsiblePersonsList.firstIndex(where: { $0 == userData}) {
                responsiblePersonsList[idx].isSelected = isSelected
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
                    self.groupsDetails = response.groups.sorted {
                        $0.groupName.localizedCaseInsensitiveCompare($1.groupName) == .orderedAscending
                    }
                    if let selectedIds = selectedIds {
                        for id in selectedIds {
                            if let index = self.searchProjects.firstIndex(where: { Int($0.groupId) == id }) {
                                self.searchProjects[index].isSelected = true
                            }
                        }
                    }

                    self.noDataFound = self.searchProjects.count <= 0
                }
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }
    }
    func fetchUsersList(selectedIds: [Int]? = nil, selecedItem: FilterType) {
        UserRequest
            .userList(params: .init(searchKey: ""))
            .makeCall(responseType: UserListForGroupRequest.Response.self) { (isLoading) in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { (response) in
                DispatchQueue.main.async {
                    if selecedItem == .observer {
                        self.observersList = response.users.sorted {
                            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                        }
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
    
    func fetchProjectAndUsersList(selectedGroupIds: [Int]? = nil, selectedResponsibleIds: [Int]? = nil) {
        FilterRequest.getContents.makeCall(responseType: FilterResponse.self) { isLoading in
            DispatchQueue.main.async {
                self.isLoading = isLoading
            }
        } success: { result in
            DispatchQueue.main.async {
                // Assign main data
                self.groupsDetails = result.projects.sorted { $0.groupName.localizedStandardCompare($01.groupName) == .orderedAscending }
                self.responsiblePersonsList = result.responsiblePersons.sorted { $0.name.localizedStandardCompare($01.name) == .orderedAscending }

                // Keep filtered search data in sync
                self.searchProjects = self.groupsDetails
                self.searchresponsiblePersonsList = self.responsiblePersonsList
                self.searchObserversUsersList = self.responsiblePersonsList // optional if observer == responsible

                // Apply previously selected IDs if any
                if let selectedGroupIds = selectedGroupIds {
                    self.selectedGroupsIds = selectedGroupIds
                }
                if let selectedResponsibleIds = selectedResponsibleIds {
                    self.selectedResponsiblePersonsIds = selectedResponsibleIds
                }

                // Handle empty state
                self.noDataFound = self.searchProjects.isEmpty && self.searchresponsiblePersonsList.isEmpty

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
