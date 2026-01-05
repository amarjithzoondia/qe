//
//  ViolationListViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 18/07/25.
//


import UIKit

class ViolationListViewModel: BaseViewModel, ObservableObject {
    let user = UserManager.getCheckOutUser()!
    @Published var searchViolations = [Violation]()
    var excelUrl: String = Constants.EMPTY_STRING
    var pageNumber: Int = 1
    var hasMorePages: Bool = true
    
    var dummyObservations = (0...10).map { item in
        Observation.dummy(observationId: item)
    }
    
    private var violations = [Violation]() {
        didSet {
            DispatchQueue.safeAsyncMain {
                self.searchViolations = self.violations
            }
        }
    }
    
    func fetchViolationsList(searchText: String?, sortType: SortedType, isInital: Bool = false, selectedProjectIds: [Int], openDate: Date?, endDate: Date?, selectedReportedByPersonIds: [Int], noProjectSpecified: Bool) {
        guard !isLoading, hasMorePages else { return }
        
        DispatchQueue.safeAsyncMain {
            self.error = nil
            self.noDataFound = false
        }
        
        let openDateFormatted = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateFormatted = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectIds
        
        ViolationsRequest.violationsList(params: .init(searchKey: searchText, pageNumber: pageNumber, sortType: sortType, projectIds: formattedProjectIds, openDate: openDateFormatted, endDate: endDateFormatted, reportedByPersons: selectedReportedByPersonIds)).makeCall(responseType: [Violation].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.safeAsyncMain {
                if isInital {
                    self.violations = []
                }
                self.violations.append(contentsOf: response)
                self.noDataFound = self.violations.count <= 0
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
    
    func sortViolation(searchText: String, sortType: SortedType, selectedProjectIds: [Int], openDate: Date?, endDate: Date?, selectedReportedByPersonIds: [Int], noProjectSpecified: Bool) {
        DispatchQueue.main.async {
            self.violations = []
            self.pageNumber = 1
            self.hasMorePages = true
            self.fetchViolationsList(searchText: searchText, sortType: sortType, selectedProjectIds: selectedProjectIds, openDate: openDate, endDate: endDate, selectedReportedByPersonIds: selectedReportedByPersonIds, noProjectSpecified: noProjectSpecified)
        }
        
    }
    
    func exportToExcel(searchKey: String, sortType: SortedType, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool, completion: @escaping () -> ()) {
        
        let openDateText = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateText = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
        
        ViolationsRequest
            .generateExcel(params: .init(searchKey: searchKey, sortBy: sortType, projectIds: formattedProjectIds, openDate: openDateText, endDate: endDateText, reportedByPersons: reportedByPersonsIds))
            .makeCall(responseType: InspectionExcelResponse.self) { (isLoading) in
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
