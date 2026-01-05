//
//  BulkUploadEmployeeViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 12/09/25.
//

import UIKit

class BulkUploadEmployeeViewModel: BaseViewModel, ObservableObject {
    @Published var employees = [Employee]()
    var pageNumber: Int = 1
    var hasMorePages: Bool = true
    
    func fetchEmployees(searchText: String?, sortType: SortedType, isInital: Bool = false, groupData: GroupData) {
        guard !isLoading, hasMorePages else { return }
        
        DispatchQueue.safeAsyncMain {
            self.error = nil
            self.noDataFound = false
        }
        
        EmployeeRequest.employeeList(params: .init(groupId: groupData.groupId, searchKey: searchText, pageNumber: pageNumber, sortType: sortType)).makeCall(responseType: [Employee].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.safeAsyncMain {
                if isInital {
                    self.employees = []
                }
                self.employees.append(contentsOf: response)
                self.noDataFound = self.employees.count <= 0
                self.pageNumber += 1
                self.hasMorePages = !response.isEmpty
            }
        } failure: { error in
            DispatchQueue.safeAsyncMain {
                self.error = error
                self.toast = error.toast
            }
        }
    }
    
    func resetPagination() {
        self.hasMorePages = true
        self.pageNumber = 1
    }
}
