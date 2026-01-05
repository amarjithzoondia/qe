//
//  EmployeeSearchViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 29/10/25.
//


import Combine
import Foundation

// MARK: - Debounce Helper ViewModel
final class EmployeeSearchViewModel: ObservableObject {
    @Published var employeeCode: String = ""
    @Published var debouncedEmployeeCode: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        $employeeCode
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.debouncedEmployeeCode, on: self)
            .store(in: &cancellables)
    }
}
