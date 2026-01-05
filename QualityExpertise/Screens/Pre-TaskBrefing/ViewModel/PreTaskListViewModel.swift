//
//  PreTaskListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 24/10/25.
//

import UIKit

class PreTaskListViewModel: BaseViewModel, ObservableObject {
    let user = UserManager.getCheckOutUser()!
    @Published var searchPreTasks = [PreTask]()
    var excelUrl: String = Constants.EMPTY_STRING
    var pageNumber: Int = 1
    var hasMorePages: Bool = true
    
    
    private var preTaskBreifings = [PreTask]() {
        didSet {
            DispatchQueue.safeAsyncMain {
                self.searchPreTasks = self.preTaskBreifings
            }
        }
    }
    
    func fetchPreTaskList(searchText: String?, sortType: SortedType, isInital: Bool = false, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool) {
        guard !isLoading, hasMorePages else { return }
        
        DispatchQueue.safeAsyncMain {
            self.error = nil
            self.noDataFound = false
        }
        
        let openDateFormatted = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateFormatted = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
    
        PreTaskRequest.list(params: .init(searchKey: searchText, pageNumber: pageNumber, sortType: sortType, projectIds: formattedProjectIds, openDate: openDateFormatted , endDate: endDateFormatted, reportedByPersons: reportedByPersonsIds)).makeCall(responseType: [PreTask].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.safeAsyncMain {
                if isInital {
                    self.preTaskBreifings = []
                }
                self.preTaskBreifings.append(contentsOf: response)
                self.noDataFound = self.preTaskBreifings.count <= 0
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
    
    func sortToolBoxTalks(searchText: String, sortType: SortedType, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool) {
        DispatchQueue.main.async {
            self.preTaskBreifings = []
            self.pageNumber = 1
            self.hasMorePages = true
            self.fetchPreTaskList(searchText: searchText, sortType: sortType, selectedProjectsIds: selectedProjectsIds, openDate: openDate, endDate: endDate, reportedByPersonsIds: reportedByPersonsIds, noProjectSpecified: noProjectSpecified)
        }
    }
    
    func exportToExcel(searchKey: String, sortType: SortedType, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool, completion: @escaping () -> ()) {
        
        let openDateText = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateText = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
        
        PreTaskRequest
            .generateExcel(params: .init(searchKey: searchKey, sortBy: sortType, projectIds: formattedProjectIds, openDate: openDateText, endDate: endDateText, reportedByPersons: reportedByPersonsIds))
            .makeCall(responseType: PreTaskExcelResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.excelUrl = response.excelUrl
                    completion()
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        }
    
    func resetPagination() {
        self.hasMorePages = true
        self.pageNumber = 1
    }
}
