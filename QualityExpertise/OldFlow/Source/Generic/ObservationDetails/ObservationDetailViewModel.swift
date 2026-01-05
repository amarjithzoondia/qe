//
//  ObservationDetailViewModel.swift
// ALNASR
//
//  Created by developer on 23/02/22.
//

import Foundation
import SwiftUI

class ObservationDetailViewModel: BaseViewModel, ObservableObject {
    @Published var observationDetails = ObservationDetails.dummy(observationId: -1)
    @Published var guestObservationDetails = GuestObservationDetails.dummy(observationId: -1)
    var isGuestUser: Bool = UserManager.getCheckOutUser()?.isGuestUser ?? false
    let observationId: Int
    var notificationId: Int?
    var pdfUrl: String = Constants.EMPTY_STRING
    
    var closeDate: String {
        return observationDetails.closeDetails?.date?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") ?? ""
    }
    
    var closedTime : String {
        return Date().timeAgo(from: observationDetails.closeDetails?.date?.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")?.toLocalTime() ?? Date())
    }
    
    var guestCloseDate: String {
        return guestObservationDetails.closeDetails?.date?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") ?? ""
    }
    
    var guestClosedTime : String {
        return Date().timeAgo(from: guestObservationDetails.closeDetails?.date?.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")?.toLocalTime() ?? Date())
    }
    
    internal init(observationId: Int, notificationId: Int? = nil) {
        self.observationId = observationId
        self.notificationId = notificationId
    }
    
    override func onRetry() {
        fetchObservationDetails()
    }

    func fetchObservationDetails() {
        if UserManager.getCheckOutUser()?.isGuestUser ?? false {
            GuestRequest
                .observationDetails(params: .init(guestUserId: UserManager.getCheckOutUser()?.userId ?? -1, observationId: observationId))
                .makeCall(responseType: GuestObservationDetails.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.guestObservationDetails = response
                    if self.guestObservationDetails.status == .closedObservations {
                        self.guestObservationDetails.status = .closeOutApproved
                    }
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        } else {
            ObservationRequest
                .observationDetails(params: .init(notificationId: notificationId ?? -1, observationId: observationId))
                .makeCall(responseType: ObservationDetails.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.observationDetails = response
                    if self.observationDetails.status == .closedObservations && self.observationDetails.group == nil {
                        self.guestObservationDetails.status = .closeOutApproved
                    }
                    UserManager.instance.notificationUnReadCount = self.observationDetails.notificationUnReadCount
                    UserManager.instance.notificationUnReadCount = self.observationDetails.pendingActionsCount
                } failure: { (error) in
                    if error.errorCode == Repository.ErrorCode.observationNotFound.rawValue {
                        NotificationCenter.default.post(name: .UPDATE_NOTIFICATION_LIST, object: nil)
                    }
                    self.error = error
                    self.toast = error.toast
                }
        }
    }
    
    func deleteObservation(completion: @escaping (_ completed: Bool) -> ()) {
        if UserManager.getCheckOutUser()?.isGuestUser ??  false {
            GuestRequest
                .deleteObservation(params: .init(guestUserId: UserManager.getCheckOutUser()?.userId ?? -1, observationId: observationId))
                .makeCall(responseType: ObservationDetailRequest.DeleteResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    completion(true)
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        } else {
            ObservationRequest
                .deleteObservation(params: .init(observationId: observationId))
                .makeCall(responseType: ObservationDetailRequest.DeleteResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    completion(true)
                } failure: { (error) in
                    self.error = error
                    self.toast = error.toast
                }
        }
    }
    
    func generatePdf(completion: @escaping (_ completed: Bool) -> ()) {
        if UserManager.getCheckOutUser()?.isGuestUser ??  false {
            GuestRequest
                .generatePdf(params: .init(guestUserId: UserManager.getCheckOutUser()?.userId ?? -1, observationId: observationId))
                .makeCall(responseType: ObservationDetailRequest.GeneratePDFResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.pdfUrl = response.pdfUrl
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        } else {
            ObservationRequest
                .generatePdf(params: .init(observationId: observationId))
                .makeCall(responseType: ObservationDetailRequest.GeneratePDFResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.pdfUrl = response.pdfUrl
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        }
    }
    
    func sharePdf(urlString: String, completion: @escaping (Data?)->()) {
        self.isLoading = true
        DownloadManager.downloadfromURL(url: urlString, completion: { data in
            self.isLoading = false
            if let data = data {
                completion(data)
            } else {
                self.toast = Toast.alert(subTitle: "Pdf could not be shared")
            }
        })
    }
    
    func getShareMessage() -> String {
        if isGuestUser {
            return "*---REPORT \(observationId)---*\n*Title:* \(guestObservationDetails.observationTitle)\n*Reported By:* \(guestObservationDetails.reportedBy)\n*Date Reported:* \(guestObservationDetails.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"))\n*Group:* No Group\n*Report Status:* \(guestObservationDetails.status.description)\n*Location:* \(guestObservationDetails.location ?? "Not Provided")\n*Responsible Person:* \(guestObservationDetails.responsiblePerson)\n*Description:* \(guestObservationDetails.description ?? "NA")\(guestObservationDetails.status == .closedObservations ? "\n\n*---CLOSE OUT---*\n*Date Closed:* \((guestObservationDetails.closeDetails?.date ?? "Not Provided").convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"))\n*Closeout Description:* \(guestObservationDetails.closeDetails?.closeDescription ?? "Not Provided")" : "")"
        }
        
        return "*---REPORT \(observationId)---*\n*Title:* \(observationDetails.observationTitle)\n*Reported By:* \(observationDetails.reportedBy)\n*Date Reported:* \(observationDetails.date.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"))\n*Group:* \((observationDetails.group != nil ? observationDetails.group?.groupName : "No Group") ?? "No Group")\n*Report Status:* \(observationDetails.status.description)\n*Location:* \(observationDetails.location ?? "Not Provided")\n*Responsible Person:* \(observationDetails.groupSpecified ?? false ?(observationDetails.responsiblePerson?.name ?? "Not Assigned") : (observationDetails.responsiblePersonName ?? "Not Assigned"))\n*Description:* \( observationDetails.description ?? "NA")\((observationDetails.status == .closedObservations) || (observationDetails.status == .closeOutApproved) ? "\n\n*---CLOSE OUT---*\n*Date Closed:* \((observationDetails.closeDetails?.date ?? "Not Provided").convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"))\n*Closed By:* \(observationDetails.closeDetails?.closedBy?.name ?? "Not Assigned") \n*Closeout Description:* \(observationDetails.closeDetails?.closeDescription ?? "Not Provided")" : "")"
    }
}
