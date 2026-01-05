//
//  NFObservationDetailViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import Foundation
import SwiftUI

class NFObservationDetailViewModel: BaseViewModel, ObservableObject {
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
                    UserManager.shared.notificationUnReadCount = response.notificationUnReadCount
                    UserManager.shared.notificationUnReadCount = response.pendingActionsCount
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
        func safeText(_ value: String?, default defaultText: String = "na".localizedString()) -> String {
            guard let text = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return defaultText }
            return text
        }

        // MARK: - Basic Fields
        let titleText = safeText(observationDetails.observationTitle)
        let reportedByText = safeText(observationDetails.reportedBy)
        
        let reportedDateText = safeText(
            observationDetails.date.convertDateFormater(
                dateFormat: "dd-MM-yyyy",
                inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                local: LocalizationService.shared.language.local
            ),
            default: "na".localizedString()
        )
        
        let projectText = safeText(observationDetails.group?.groupName, default: "na".localizedString())
        let statusText = safeText(observationDetails.status.description)
        let locationText = safeText(observationDetails.location, default: "na".localizedString())

        // MARK: - Responsible Person
        let responsiblePersonText: String
        if observationDetails.groupSpecified ?? false {
            responsiblePersonText = safeText(observationDetails.responsiblePerson?.name, default: "na".localizedString())
        } else {
            responsiblePersonText = safeText(observationDetails.responsiblePersonName, default: "na".localizedString())
        }

        // MARK: - Images
        let imageCount = observationDetails.imageDescription?.count ?? 0
        let imagesText: String
        if imageCount == 0 {
            imagesText = "no_images".localizedString()
        } else if imageCount == 1 {
            imagesText = "1 " + "image_attached".localizedString()
        } else {
            imagesText = "\(imageCount) " + "images_attached".localizedString()
        }

        // MARK: - Description
        let descriptionText = safeText(observationDetails.description)

        // MARK: - Closeout Details
        var closeoutText = ""
        if observationDetails.status == .closedObservations || observationDetails.status == .closeOutApproved {
            let closeDateText = safeText(
                observationDetails.closeDetails?.date?.convertDateFormater(
                    dateFormat: "dd-MM-yyyy",
                    inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                    local: LocalizationService.shared.language.local
                ),
                default: "na".localizedString()
            )
            let closedByText = safeText(observationDetails.closeDetails?.closedBy?.name, default: "na".localizedString())
            let closeDescriptionText = safeText(observationDetails.closeDetails?.closeDescription, default: "na".localizedString())

            closeoutText = """

            *--- \("close_out".localizedString().uppercased()) ---*
            *\("date_closed".localizedString().uppercased()) :* \(closeDateText)
            *\("closed_by".localizedString().uppercased()) :* \(closedByText)
            *\("closeout_description".localizedString().uppercased()) :* \(closeDescriptionText)
            """
        }

        // MARK: - Localized labels
        let header = "observation_report".localizedString().uppercased()
        let titleLabel = "title".localizedString().uppercased()
        let reportedByLabel = "reported_by".localizedString().uppercased()
        let reportedDateLabel = "date_reported".localizedString().uppercased()
        let projectLabel = "project".localizedString().uppercased()
        let statusLabel = "report_status".localizedString().uppercased()
        let locationLabel = "location".localizedString().uppercased()
        let responsiblePersonLabel = "responsible_person".localizedString().uppercased()
        let descriptionLabel = "description".localizedString().uppercased()
        let imagesLabel = "images_small".localizedString().uppercased()

        // MARK: - Return Final Message (LTR/RTL auto-handled)
        return """
        *--- \(header) \(observationId) ---*
        *\(titleLabel) :* \(titleText)
        *\(reportedByLabel) :* \(reportedByText)
        *\(reportedDateLabel) :* \(reportedDateText)
        *\(projectLabel) :* \(projectText)
        *\(statusLabel) :* \(statusText)
        *\(locationLabel) :* \(locationText)
        *\(responsiblePersonLabel) :* \(responsiblePersonText)
        *\(descriptionLabel) :* \(descriptionText)\(closeoutText)
        *\(imagesLabel) :* \(imagesText)
        """
    }




}
