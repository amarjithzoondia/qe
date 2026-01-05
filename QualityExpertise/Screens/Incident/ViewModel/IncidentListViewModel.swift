//
//  IncidentListViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

import UIKit
import Combine

final class IncidentListViewModel: BaseViewModel, ObservableObject {
    
    // MARK: - Properties
    private let user = UserManager.getCheckOutUser()!
    
    @Published var searchIncidents: [Incident] = []
    @Published var searchText: String = ""  // Debounced search input
    @Published var isListSorted: Bool = false
    
    var excelUrl: String = Constants.EMPTY_STRING
    private(set) var pageNumber: Int = 1
    private(set) var hasMorePages: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Data Source
    private var incidents: [Incident] = [] {
        didSet {
            DispatchQueue.safeAsyncMain {
                self.searchIncidents = self.incidents
            }
        }
    }
    
    // MARK: - Filters
    private var lastFilters: (
        selectedProjectsIds: [Int],
        openDate: Date?,
        endDate: Date?,
        reportedByPersonsIds: [Int],
        incidentTypesIds: [Int],
        noProjectSpecified: Bool
    )?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupSearchSubscription()
    }
}

// MARK: - Search & Debounce
extension IncidentListViewModel {
    
    /// Sets up debounced search subscription to avoid excessive API calls.
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                self.resetPagination()
                
                guard let filters = self.lastFilters else { return }
                
                let sortType: SortedType = self.isListSorted ? .descending : .ascending
                self.fetchIncidentsList(
                    searchText: query.isEmpty ? nil : query,
                    sortType: sortType,
                    isInitial: true,
                    selectedProjectsIds: filters.selectedProjectsIds,
                    openDate: filters.openDate,
                    endDate: filters.endDate,
                    reportedByPersonsIds: filters.reportedByPersonsIds,
                    incidentTypesIds: filters.incidentTypesIds,
                    noProjectSpecified: filters.noProjectSpecified
                )
            }
            .store(in: &cancellables)
    }
}

// MARK: - Data Fetching
extension IncidentListViewModel {
    
    func updateFilters(selectedProjectsIds: [Int],
                       openDate: Date?,
                       endDate: Date?,
                       reportedByPersonsIds: [Int],
                       incidentTypesIds: [Int],
                       noProjectSpecified: Bool) {
        lastFilters = (
            selectedProjectsIds,
            openDate,
            endDate,
            reportedByPersonsIds,
            incidentTypesIds,
            noProjectSpecified
        )
    }
    
    /// Fetches the incident list with pagination, filters, and sorting.
    func fetchIncidentsList(searchText: String?,
                            sortType: SortedType,
                            isInitial: Bool = false,
                            selectedProjectsIds: [Int],
                            openDate: Date?,
                            endDate: Date?,
                            reportedByPersonsIds: [Int],
                            incidentTypesIds: [Int],
                            noProjectSpecified: Bool) {
        
        guard !isLoading, hasMorePages else { return }
        
        DispatchQueue.safeAsyncMain {
            self.error = nil
            self.noDataFound = false
        }
        
        let openDateFormatted = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateFormatted = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        
        let formattedProjectIds = noProjectSpecified ? [-1] : selectedProjectsIds
        
        IncidentRequest.incidentList(
            params: .init(
                searchKey: searchText,
                pageNumber: pageNumber,
                sortType: sortType,
                projectIds: formattedProjectIds,
                openDate: openDateFormatted,
                endDate: endDateFormatted,
                reportedByPersons: reportedByPersonsIds,
                incidentTypes: incidentTypesIds
            )
        )
        .makeCall(responseType: [Incident].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.safeAsyncMain {
                if isInitial {
                    self.incidents.removeAll()
                }
                self.incidents.append(contentsOf: response)
                self.noDataFound = self.incidents.isEmpty
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
}

// MARK: - Sorting
extension IncidentListViewModel {
    
    func sortIncidents(searchText: String,
                        sortType: SortedType,
                        selectedProjectsIds: [Int],
                        openDate: Date?,
                        endDate: Date?,
                        reportedByPersonsIds: [Int],
                        incidentTypesIds: [Int],
                        noProjectSpecified: Bool) {
        
        DispatchQueue.safeAsyncMain {
            self.incidents.removeAll()
            self.pageNumber = 1
            self.hasMorePages = true
            
            self.fetchIncidentsList(
                searchText: searchText.isEmpty ? nil : searchText,
                sortType: sortType,
                selectedProjectsIds: selectedProjectsIds,
                openDate: openDate,
                endDate: endDate,
                reportedByPersonsIds: reportedByPersonsIds,
                incidentTypesIds: incidentTypesIds,
                noProjectSpecified: noProjectSpecified
            )
        }
    }
}

// MARK: - Excel Export
extension IncidentListViewModel {
    
    func exportToExcel(searchKey: String,
                       sortType: SortedType,
                       selectedProjectsIds: [Int],
                       openDate: Date?,
                       endDate: Date?,
                       reportedByPersonsIds: [Int],
                       incidentTypesIds: [Int],
                       noProjectSpecified: Bool,
                       completion: @escaping () -> Void) {
        
        let openDateText = openDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        let endDateText = endDate?.formattedDateString(format: "dd-MM-yyyy") ?? ""
        
        let formattedProjectsIds = noProjectSpecified ? [-1] : selectedProjectsIds
        
        IncidentRequest
            .generateExcel(
                params: .init(
                    searchKey: searchKey,
                    sortBy: sortType,
                    projectIds: formattedProjectsIds,
                    openDate: openDateText,
                    endDate: endDateText,
                    reportedByPersons: reportedByPersonsIds,
                    incidentTypes: incidentTypesIds
                )
            )
            .makeCall(responseType: IncidentExcelResponse.self) { isLoading in
                self.isLoading = isLoading
            } success: { response in
                self.excelUrl = response.excelUrl
                completion()
            } failure: { error in
                self.error = error
                self.toast = error.toast
            }
    }
}

// MARK: - Helpers
extension IncidentListViewModel {
    
    func resetPagination() {
        hasMorePages = true
        pageNumber = 1
    }
}
