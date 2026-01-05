//
//  BulkUploadEmployeeViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 12/09/25.
//

import UIKit

class BulkUploadEmployeeViewModel: BaseViewModel, ObservableObject {
    @Published var employees = [Employee]()
    
    func fetchEmployees() {
        self.employees = (0..<20).map { _ in Employee.dummy() }
//        self.noDataFound =  true
    }
}
