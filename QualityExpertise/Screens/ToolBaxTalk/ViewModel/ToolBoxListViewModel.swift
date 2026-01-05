//
//  ToolBoxListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

import UIKit

class ToolBoxListViewModel: BaseViewModel, ObservableObject {
    let user = UserManager.getCheckOutUser()!
    @Published var searchToolBoxTalks = [ToolBoxTalk]()
    var excelUrl: String = Constants.EMPTY_STRING
    var pageNumber: Int = 1
    var hasMorePages: Bool = true
    
    var dummyObservations = (0...10).map { item in
        Observation.dummy(observationId: item)
    }
    
    private var toolBoxTalks = [ToolBoxTalk]() {
        didSet {
            DispatchQueue.safeAsyncMain {
                self.searchToolBoxTalks = self.toolBoxTalks
            }
        }
    }
    
    func fetchToolBoxList(searchText: String?, sortType: SortedType, isInital: Bool = false, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool) {
        guard !isLoading, hasMorePages else { return }
        
        DispatchQueue.safeAsyncMain {
            self.error = nil
            self.noDataFound = false
        }
        
        let openDateFormatted = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateFormatted = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
    
        ToolBoxRequest.toolBoxList(params: .init(searchKey: searchText, pageNumber: pageNumber, sortType: sortType, projectIds: formattedProjectIds, openDate: openDateFormatted , endDate: endDateFormatted, reportedByPersons: reportedByPersonsIds)).makeCall(responseType: [ToolBoxTalk].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.safeAsyncMain {
                if isInital {
                    self.toolBoxTalks = []
                }
                self.toolBoxTalks.append(contentsOf: response)
                self.noDataFound = self.toolBoxTalks.count <= 0
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
            self.toolBoxTalks = []
            self.pageNumber = 1
            self.hasMorePages = true
            self.fetchToolBoxList(searchText: searchText, sortType: sortType, selectedProjectsIds: selectedProjectsIds, openDate: openDate, endDate: endDate, reportedByPersonsIds: reportedByPersonsIds, noProjectSpecified: noProjectSpecified)
        }
        
    }
    
    func exportToExcel(searchKey: String, sortType: SortedType, selectedProjectsIds: [Int], openDate: Date?, endDate: Date?, reportedByPersonsIds: [Int], noProjectSpecified: Bool, completion: @escaping () -> ()) {
        
        let openDateText = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateText = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
        
        ToolBoxRequest
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
