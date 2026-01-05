//
//  Employee.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

import Foundation

struct Employee: Codable, Identifiable, Equatable {
    var id: Int
    var employeeCode: String?
    var employeeName: String
    var companyName: String?
    var profession: String?
    
    static func dummy() -> Employee {
        return Employee(id: -1, employeeCode: "1245", employeeName: "Sample", companyName: "Sample Company", profession: "Employee")
    }
}
