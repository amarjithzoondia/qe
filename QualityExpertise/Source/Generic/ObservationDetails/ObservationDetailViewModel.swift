//
//  ObservationDetailViewModel.swift
// QualityExpertise
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
        return observationDetails.closeDetails?.date?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local) ?? ""
    }
    
    var closedTime : String {
        return Date().timeAgo(from: observationDetails.closeDetails?.date?.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)?.toLocalTime() ?? Date())
    }
    
    var guestCloseDate: String {
        return guestObservationDetails.closeDetails?.date?.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local) ?? ""
    }
    
    var guestClosedTime : String {
        return Date().timeAgo(from: guestObservationDetails.closeDetails?.date?.repoDate(inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", local: LocalizationService.shared.language.local)?.toLocalTime() ?? Date())
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
                    UserManager.shared.notificationUnReadCount = self.observationDetails.notificationUnReadCount
                    UserManager.shared.notificationUnReadCount = self.observationDetails.pendingActionsCount
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
        DispatchQueue.main.async {
            self.pdfLoading = true
        }
        if UserManager.getCheckOutUser()?.isGuestUser ??  false {
            GuestRequest
                .generatePdf(params: .init(guestUserId: UserManager.getCheckOutUser()?.userId ?? -1, observationId: observationId))
                .makeCall(responseType: ObservationDetailRequest.GeneratePDFResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                    self.pdfLoading = false
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
                    self.pdfLoading = false
                } success: { (response) in
                    self.pdfUrl = response.pdfUrl
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        }
    }
    
    func sharePdf(urlString: String, completion: @escaping (URL?)->()) {
        self.isLoading = true
        DownloadManager.downloadfromURL(url: urlString) { data in
            self.isLoading = false
            guard let data = data else {
                self.toast = Toast.alert(subTitle: "pdf_share_error".localizedString())
                completion(nil)
                return
            }
            // Save to temporary directory with custom file name
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\("QualityExpertise - Observations(\(self.observationId))").pdf")
            do {
                try data.write(to: tempURL)
                completion(tempURL)
            } catch {
                self.toast = Toast.alert(subTitle: "pdf_save_error".localizedString())
                completion(nil)
            }
        }
    }
    
    func getShareMessage() -> String {
        
        // MARK: - Helper
        func safeText(_ value: String?, default defaultText: String = "N/A") -> String {
            guard let text = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return defaultText }
            return text
        }
        
        // MARK: - Shared Image Text Generator
        func localizedImagesText(count: Int) -> String {
            if count == 0 {
                return "no_images".localizedString()
            } else if count == 1 {
                return "1 " + "image_attached".localizedString()
            } else {
                return "\(count) " + "images_attached".localizedString()
            }
        }
        
        // MARK: - Guest User Report
        if isGuestUser {
            let titleText = safeText(guestObservationDetails.observationTitle)
            let reportedByText = safeText(guestObservationDetails.reportedBy)
            let reportedDateText = safeText(
                guestObservationDetails.date.convertDateFormater(
                    dateFormat: "dd-MM-yyyy",
                    inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                    local: LocalizationService.shared.language.local
                ),
                default: "not_provided".localizedString()
            )
            let projectText = "no_group".localizedString()
            let statusText = safeText(guestObservationDetails.status.description)
            let locationText = safeText(guestObservationDetails.location, default: "not_provided".localizedString())
            let responsiblePersonText = safeText(guestObservationDetails.responsiblePerson, default: "not_assigned".localizedString())
            let descriptionText = safeText(guestObservationDetails.description)
            let imagesText = localizedImagesText(count: guestObservationDetails.imageDescription?.count ?? 0)
            
            // Close-out Section
            var closeoutText = ""
            if guestObservationDetails.status == .closedObservations {
                let closeDateText = safeText(
                    guestObservationDetails.closeDetails?.date?.convertDateFormater(
                        dateFormat: "dd-MM-yyyy",
                        inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                        local: LocalizationService.shared.language.local
                    ),
                    default: "not_provided".localizedString()
                )
                let closeDescriptionText = safeText(guestObservationDetails.closeDetails?.closeDescription, default: "not_provided".localizedString())
                
                closeoutText = """

    *--- \("close_out".localizedString()) ---*
    *\("date_closed".localizedString()) :* \(closeDateText)
    *\("closeout_description".localizedString()) :* \(closeDescriptionText)
    """
            }
            
            let message = """
    *--- \("observation_report".localizedString()) \(observationId) ---*
    *\("title".localizedString()) :* \(titleText)
    *\("reported_by".localizedString()) :* \(reportedByText)
    *\("date_reported".localizedString()) :* \(reportedDateText)
    *\("group".localizedString()) :* \(projectText)
    *\("report_status".localizedString()) :* \(statusText)
    *\("location".localizedString()) :* \(locationText)
    *\("responsible_person".localizedString()) :* \(responsiblePersonText)
    *\("description".localizedString()) :* \(descriptionText)\(closeoutText)
    *\("images_small".localizedString()) :* \(imagesText)
    """
            let rtlMessage = "\u{202B}" + message + "\u{202C}"
            print(rtlMessage)
            return rtlMessage
            
        } else {
            // MARK: - Regular Observation
            let titleText = safeText(observationDetails.observationTitle)
            let reportedByText = safeText(observationDetails.reportedBy)
            let observationDateText = safeText(
                observationDetails.date.convertDateFormater(
                    dateFormat: "dd-MM-yyyy",
                    inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                    local: LocalizationService.shared.language.local
                ),
                default: "not_provided".localizedString()
            )
            let projectText = safeText(observationDetails.group?.groupName, default: "no_group".localizedString())
            let statusText = safeText(observationDetails.status.description)
            let locationText = safeText(observationDetails.location, default: "not_provided".localizedString())
            
            let responsiblePersonText: String
            if observationDetails.groupSpecified ?? false {
                responsiblePersonText = safeText(observationDetails.responsiblePerson?.name, default: "not_assigned".localizedString())
            } else {
                responsiblePersonText = safeText(observationDetails.responsiblePersonName, default: "not_assigned".localizedString())
            }
            
            let descriptionText = safeText(observationDetails.description)
            let imagesText = localizedImagesText(count: observationDetails.imageDescription?.count ?? 0)
            
            // Close-out Section
            var closeoutText = ""
            if observationDetails.status == .closedObservations || observationDetails.status == .closeOutApproved {
                let closeDateText = safeText(
                    observationDetails.closeDetails?.date?.convertDateFormater(
                        dateFormat: "dd-MM-yyyy",
                        inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                        local: LocalizationService.shared.language.local
                    ),
                    default: "not_provided".localizedString()
                )
                let closedByText = safeText(observationDetails.closeDetails?.closedBy?.name, default: "not_assigned".localizedString())
                let closeDescriptionText = safeText(observationDetails.closeDetails?.closeDescription, default: "not_provided".localizedString())
                
                closeoutText = """

    *--- \("close_out".localizedString()) ---*
    *\("date_closed".localizedString()) :* \(closeDateText)
    *\("closed_by".localizedString()) :* \(closedByText)
    *\("closeout_description".localizedString()) :* \(closeDescriptionText)
    """
            }
            
            let message = """
    *--- \("observation_report".localizedString()) \(observationId) ---*
    *\("title".localizedString()) :* \(titleText)
    *\("reported_by".localizedString()) :* \(reportedByText)
    *\("observation_date".localizedString()) :* \(observationDateText)
    *\("date_reported".localizedString()) :* \(observationDateText)
    *\("group".localizedString()) :* \(projectText)
    *\("report_status".localizedString()) :* \(statusText)
    *\("location".localizedString()) :* \(locationText)
    *\("responsible_person".localizedString()) :* \(responsiblePersonText)
    *\("description".localizedString()) :* \(descriptionText)\(closeoutText)
    *\("images_small".localizedString()) :* \(imagesText)
    """
            let rtlMessage = "\u{202B}" + message + "\u{202C}"
            print(rtlMessage)
            return rtlMessage
        }
    }


}
