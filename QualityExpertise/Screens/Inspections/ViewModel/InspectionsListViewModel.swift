//
//  InspectionsListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 04/06/25.
//

import UIKit

class InspectionsListViewModel: BaseViewModel, ObservableObject {
    let user = UserManager.getCheckOutUser()!
    @Published var searchInspections = [Inspections]()
    var excelUrl: String = Constants.EMPTY_STRING
    var pageNumber: Int = 1
    var hasMorePages: Bool = true
    
    var dummyObservations = (0...10).map { item in
        Observation.dummy(observationId: item)
    }
    
    var inspections = [Inspections]() {
        didSet {
            searchInspections = inspections
        }
    }
    
    func fetchInspectionsList(searchText: String?, sortType: SortedType, isInital: Bool = false, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool) {
        
        guard !isLoading, hasMorePages else { return }
        
        DispatchQueue.safeAsyncMain {
            self.error = nil
            self.noDataFound = false
        }
        
        let openDateText = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateText = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
        
        InspectionsRequest.inspectionList(params: .init(searchKey: searchText, pageNumber: pageNumber, sortType: sortType, projectIds: formattedProjectIds, openDate: openDateText, endDate: endDateText, reportedByPersons: reportedByPersonsIds)).makeCall(responseType: [Inspections].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.main.async {
                if isInital {
                    self.inspections = []
                }
                self.inspections.append(contentsOf: response)
                self.noDataFound = self.inspections.count <= 0
                self.pageNumber += 1
                self.hasMorePages = !response.isEmpty
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }

    }
    
    func exportToExcel(searchKey: String, sortType: SortedType, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool, completion: @escaping () -> ()) {
        
        let openDateText = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateText = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
        
        InspectionsRequest
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
    
    func sortInspections(searchText: String, sortType: SortedType, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool) {
        DispatchQueue.main.async {
            self.inspections = []
            self.pageNumber = 1
            self.hasMorePages = true
            self.fetchInspectionsList(searchText: searchText, sortType: sortType, selectedProjectsIds: selectedProjectsIds, openDate: openDate, endDate: endDate, reportedByPersonsIds: reportedByPersonsIds, noProjectSpecified: noProjectSpecified)
        }
        
    }
}
