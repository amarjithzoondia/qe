//
//  CreateViolationViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 18/07/25.
//


import UIKit
import SwiftUI
import CoreData

class CreateViolationViewModel: BaseViewModel, ObservableObject {
    
    let draftViolation: Violation?
    let violation: Violation?
    
    var pdfUrl: String = Constants.EMPTY_STRING
    private let localDBRepository = ViolationDBRepository()
    private let localDBUseCase: ViolationDBUseCase
    
    internal init(violation: Violation?, draftViolation: Violation?) {
        self.violation = violation
        self.draftViolation = draftViolation
        localDBUseCase = ViolationDBUseCase(repository: localDBRepository)
    }
    
    func publish(employeeName: String, employeeId: String, violationDate: Date?, location: String, description: String, groupData: GroupData?, image: [ImageData], reportedBy: String, completion: @escaping (_ completed: Bool) -> ()) {
        
        var validatedEmployeeName: String?
        var validatedEmployeeId: String?
        var validatedViolationDate: String?
        
        do {
            validatedEmployeeName = try employeeName.validatedText(validationType: .requiredField(field: "employee_name".localizedString()))
            validatedEmployeeId = try employeeId.validatedText(validationType: .requiredField(field: "employee_id".localizedString()))
            validatedViolationDate = try (violationDate?.formattedDateString(format: Constants.DateFormat.REPO_DATE) ?? "").validatedText(validationType: .requiredField(field: "date".localizedString()))
        } catch {
            toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
            return
        }

        let params = ViolationParams(
            facilitiesId: groupData?.groupId,
            employeeName: validatedEmployeeName!,
            employeeId: validatedEmployeeId!,
            violationDate: validatedViolationDate!,
            location: location,
            description: description,
            images: image,
            reportedBy: reportedBy
        )

        ViolationsRequest.addViolations(params: params).makeCall(responseType: ViolationCreationResponse.self) { isLoading in
            self.isLoading = isLoading
        } success: { [weak self] response in
            guard let self else { return }
            DispatchQueue.main.async {
                if let draftViolation = self.draftViolation {
                    do {
                        try self.localDBUseCase.deleteViolation(draftViolation)
                    } catch {
                        self.toast = "failed_draft_delete".localizedString().infoToast
                    }
                }
                
                completion(true)
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }
    }

    
    func fetchViolationDetails(completion: @escaping (_ violation: Violation?) -> ()) {
        if let draftViolation {
            completion(draftViolation)
            return
        }
          
        guard let violation else {
            return
        }
        
        ViolationsRequest.violationsDeatil(params: .init(id: violation.id)).makeCall(responseType:Violation.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            completion(response)
            
        } failure: { error in
            self.error = error
            self.toast = error.toast
            completion(nil)
        }
    }
    
    func generatePdf(violation: Violation, completion: @escaping (_ completed: Bool) -> ()) {
        DispatchQueue.main.async {
            self.pdfLoading = true
        }
        ViolationsRequest
            .generatePdf(params: .init(violationId: violation.id))
            .makeCall(responseType: ViolationPdfResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                self.pdfLoading = false
                } success: { (response) in
                    self.pdfUrl = response.pdfUrl
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        }
    
    func getShareMessage(violation: Violation) -> String {
        
        // MARK: - Helper functions
        func safeText(_ value: String?, default defaultText: String = "na".localizedString()) -> String {
            guard let text = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                return defaultText
            }
            return text
        }
        
        func convertUTCToLocal(utcString: String, inputFormat: String = "yyyy-MM-dd HH:mm:ss") -> String? {
            let formatter = DateFormatter()
            formatter.dateFormat = inputFormat
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            guard let date = formatter.date(from: utcString) else { return nil }
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            return formatter.string(from: date)
        }
        
        // MARK: - Facility Name
        let facilityName = safeText(violation.facilities?.groupName, default: "na".localizedString())
        
        // MARK: - Location
        let locationText = safeText(violation.location, default: "na".localizedString())
        
        // MARK: - Description
        let descriptionText = safeText(violation.description, default: "na".localizedString())
        
        // MARK: - Employee Info
        let employeeName = safeText(violation.employeeName)
        let employeeId = safeText(violation.employeeId)
        let violationDate = safeText(violation.violationDate)
        
        // MARK: - Images (smart plural handling)
        let imageCount = violation.images?.count ?? 0
        let imagesText: String
        if imageCount == 0 {
            imagesText = "no_images".localizedString()
        } else if imageCount == 1 {
            imagesText = "1 " + "image_attached".localizedString()
        } else {
            imagesText = "\(imageCount) " + "images_attached".localizedString()
        }
        
        // MARK: - Dates and Reporter
        let reportedOnText = convertUTCToLocal(utcString: violation.createdAt) ?? "N/A"
        let reportedByText = safeText(violation.reportedBy)
        
        // MARK: - Localized labels
        let header = "violation_report".localizedString().uppercased()
        let employeeNameLabel = "employee_name".localizedString().uppercased()
        let employeeIdLabel = "employee_id".localizedString().uppercased()
        let violationDateLabel = "violation_date".localizedString().uppercased()
        let projectLabel = "project".localizedString().uppercased()
        let locationLabel = "location".localizedString().uppercased()
        let descriptionLabel = "description".localizedString().uppercased()
        let imagesLabel = "images_small".localizedString().uppercased()
        let reportedOnLabel = "reported_on_small".localizedString().uppercased()
        let reportedByLabel = "reported_by_small".localizedString().uppercased()
        
        // MARK: - Return message (no RTL logic)
        return """
        *--- \(header) \(violation.id) ---*
        *\(employeeNameLabel) :* \(employeeName)
        *\(employeeIdLabel) :* \(employeeId)
        *\(violationDateLabel) :* \(violationDate)
        *\(projectLabel) :* \(facilityName)
        *\(locationLabel) :* \(locationText)
        *\(descriptionLabel) :* \(descriptionText)
        *\(imagesLabel) :* \(imagesText)
        *\(reportedOnLabel) :* \(reportedOnText)
        *\(reportedByLabel) :* \(reportedByText)
        """
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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\("QualityExpertise - Violations(\(self.violation?.id ?? -1))").pdf")
            do {
                try data.write(to: tempURL)
                completion(tempURL)
            } catch {
                self.toast = Toast.alert(subTitle: "pdf_save_error".localizedString())
                completion(nil)
            }
        }
    }
    
    func saveAsDraft(employeeName: String, employeeId: String, violationDate: Date?, location: String, description: String, groupData: GroupData?, image: [ImageData], reportedBy: String, completion: @escaping (_ completed: Bool) -> ()) {
        
        do {
            let employeeName = try employeeName.validatedText(validationType: .requiredField(field: "employee_name".localizedString()))
            let employeeID = try employeeId.validatedText(validationType: .requiredField(field: "employee_id".localizedString()))
            let violationDate = try (violationDate?.formattedDateString(format: Constants.DateFormat.REPO_DATE) ?? "").validatedText(validationType: .requiredField(field: "date".localizedString()))
            let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            //-1 for new items, id will be autoincrement before saving
            let violation = Violation(
                id: draftViolation?.id ?? -1,
                employeeName: employeeName,
                employeeId: employeeID,
                violationDate: violationDate,
                location: location,
                description: description,
                createdAt: createdAt,
                facilities: groupData,
                images: image,
                reportedBy: reportedBy
            )
            try localDBUseCase.saveViolations([violation])
            completion(true)
            return
            
        } catch {
            toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
        }
        
        completion(false)
    }
}
