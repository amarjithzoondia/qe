//
//  ViolationListViewModel 2.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//


import UIKit

class ViolationListViewModel: BaseViewModel, ObservableObject {
    let user = UserManager.getCheckOutUser()!
    @Published var searchViolations = [Violation]()
    var excelUrl: String = Constants.EMPTY_STRING
    
    var dummyObservations = (0...10).map { item in
        Observation.dummy(observationId: item)
    }
    
    var inspections = [Violation]() {
        didSet {
            searchViolations = [Violation.dummy()]
            // searchViolations = inspections
        }
    }
    
    func fetchInspectionsList(searchText: String?) {
        self.error = nil
        ViolationsRequest.violationsList(params: .init(searchKey: searchText)).makeCall(responseType: [Violation].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.main.async {
                self.inspections = response
                self.noDataFound = self.inspections.count <= 0
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }

    }
    
    func exportToExcel(searchKey: String, sortType: SortedType, completion: @escaping () -> ()) {
        InspectionsRequest
            .generateExcel(params: .init(searchKey: searchKey, sortBy: sortType))
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
}