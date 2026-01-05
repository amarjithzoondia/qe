//
//  ObservationListViewModel.swift
// ALNASR
//
//  Created by developer on 10/02/22.
//

import Foundation
import SwiftUI
import AppTrackingTransparency
import AdSupport

class ObservationListViewModel: BaseViewModel, ObservableObject {
    let user = UserManager.getCheckOutUser()!
    @Published var searchObservations = [Observation]()
    var excelUrl: String = Constants.EMPTY_STRING
    @Published var addTrackingAuthStatus: ATTrackingManager.AuthorizationStatus = .authorized
    var dummyObservations = (0...10).map { item in
        Observation.dummy(observationId: item)
    }
    
    var observations = [Observation]() {
        didSet {
            searchObservations = observations
        }
    }
    
    func search(key: String) {
        let result = key.isEmpty ? observations : observations.filter({ $0.observationTitle.lowercased().contains(key.lowercased()) })
        searchObservations = result
    }
    
    internal override init() {
        super.init()
        
        fetchObservationList()
    }
    
    override func onRetry() {
        fetchObservationList()
    }

    
    func fetchObservationList(searchText: String? = "", isOpenObservationSelected: Bool? = false, isClosedObservationSelected: Bool? = false, selectedGroupsIds: [Int]? = nil, selectedObserversIds: [Int]? = nil, selectedResponsiblePersonsIds: [Int]? = nil, startDate: Date? = nil, endDate: Date? = nil, noGroupSpecified: Bool? = false) {
        if user.isGuestUser {
            GuestRequest
                .list(params: .init(guestUserId: user.userId, searchKey: searchText ?? ""))
                .makeCall(responseType: ObservationRequest.ListResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    DispatchQueue.main.async {
                        self.observations = response.observations
                        self.observations.indices.filter({self.observations[$0].status == .closedObservations}).forEach({self.observations[$0].status = .closeOutApproved})
                        self.noDataFound = self.observations.count <= 0
                    }
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        } else {
            var status = Observation.Status.allObservations
            if isOpenObservationSelected ?? false {
                status = .openObservations
            } else if isClosedObservationSelected ?? false {
                status = .closedObservations
            }
            
            let startDate = startDate?.repoDateString
            let endDate = endDate?.repoDateString
            
            var groupSpecified: Int = -1
            if selectedGroupsIds?.isEmpty ?? false {
                if noGroupSpecified ??  false {
                    groupSpecified = 0
                } else {
                    groupSpecified = -1
                }
            } else {
                groupSpecified = 1
            }

            ObservationRequest
                .observationList(params: .init(searchKey: searchText ?? "", status: status, groupIds: selectedGroupsIds ?? [], observers: selectedObserversIds ?? [], responsiblePersons: selectedResponsiblePersonsIds ?? [], openDate: startDate ?? "", closeDate: endDate ?? "", groupSpecified: groupSpecified, notificationId: -1))
                .makeCall(responseType: ObservationRequest.ListResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    DispatchQueue.main.async {
                        self.observations = response.observations
                        self.observations.indices.filter({self.observations[$0].status == .closedObservations && self.observations[$0].group == nil}).forEach({self.observations[$0].status = .closeOutApproved})
                        UserManager.instance.notificationUnReadCount = response.notificationUnReadCount ?? 0
                        UserManager.instance.pendingActionsCount = response.pendingActionsCount ?? 0
                        self.noDataFound = self.observations.count <= 0
                    }
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        }
    }
    
    func exportToExcel(completion: @escaping () -> ()) {
        if user.isGuestUser {
            GuestRequest
                .exportToExcel(params: .init(guestUserId: user.userId, searchKey: ""))
                .makeCall(responseType: ObservationRequest.ExportToexcelResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.excelUrl = response.excelUrl
                    completion()
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        } else {
            ObservationRequest
                .exportToExcel(params: .init(searchKey: "", status: Observation.Status.allObservations, groupIds: [], observers: [], responsiblePersons: [], openDate: "", closeDate: "", groupSpecified: 1, notificationId: -1))
                .makeCall(responseType: ObservationRequest.ExportToexcelResponse.self) { (isLoading) in
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
    
    func requestIDFA() {
        
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          DispatchQueue.main.async {
              self.addTrackingAuthStatus = status
          }
      })
    }
}
