//
//  CreateIncidentViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//
import UIKit
import SwiftUI
import CoreData

class CreateIncidentViewModel: BaseViewModel, ObservableObject {
    
    let draftIncident: Incident?
    let incident: Incident?
    @Published var employees: [Employee] = []
    
    var pdfUrl: String = Constants.EMPTY_STRING
    private let localDBRepository = IncidentDBRepository()
    private let localDBUseCase: IncidentDBUseCase
    
    internal init(incident: Incident?, draftIncident: Incident?) {
        self.incident = incident
        self.draftIncident = draftIncident
        localDBUseCase = IncidentDBUseCase(repository: localDBRepository)
    }
    
    func fetchEmployees() {
        DispatchQueue.safeAsyncMain {
            self.error = nil
            self.noDataFound = false
        }
        
        EmployeeRequest.allList.makeCall(responseType: [Employee].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.safeAsyncMain {
                self.employees = response
                self.noDataFound = self.employees.count <= 0
            }
        } failure: { error in
            DispatchQueue.safeAsyncMain {
                self.error = error
                self.toast = error.toast
            }
        }
    }
    
    
    func publish(id: Int, date: Date?, time: Date?, incidentLocation: String?, incidentType: [Int], injuredEmployees: [Employee], description: String?, corrections: String?, facilities: GroupData?, images: [ImageData]?, isInjuredTrue: Bool, isInjuredFalse: Bool, reportedBy: String, completion: @escaping (Bool) -> ()) {
        
        let formattedDate = date?.formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
        let formattedTime = time?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
        let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
        
        if reportedBy.isEmpty {
            self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "reported_by_is_empty".localizedString())
            return
        }
        
        if !isInjuredTrue && !isInjuredFalse {
            self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
            return
        }
        
        if isInjuredTrue && injuredEmployees.isEmpty {
            self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "enter_injured_employees_to_proceed".localizedString())
            return
        }
        
        
        guard let dateStr = formattedDate, !dateStr.isEmpty,
              let timeStr = formattedTime, !timeStr.isEmpty,
              !incidentType.isEmpty else {
            self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
            return
        }
        
        let params: IncidentParams = IncidentParams(
            incidentDate: dateStr,
            incidentTime: timeStr,
            incidentLocation: incidentLocation,
            incidentType: incidentType,
            injuredEmployees: injuredEmployees,
            description: description,
            corrections: corrections,
            createdAt: createdAt,
            facilitiesId: facilities?.groupId,
            images: images,
            reportedBy: reportedBy
        )

        IncidentRequest.addIncident(params: params).makeCall(responseType: IncidentCreationResponse.self) { isLoading in
            self.isLoading = isLoading
        } success: { [weak self] response in
            guard let self else { return }
            DispatchQueue.main.async {
                if let draftIncident = self.draftIncident {
                    do {
                        try self.localDBUseCase.deleteIncidents(draftIncident)
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

    
    func fetchIncidentDetails(completion: @escaping (_ incident: Incident?) -> ()) {
        if let draftIncident {
            completion(draftIncident)
            return
        }
          
        guard let incident else {
            return
        }
        
        IncidentRequest.incidentDeatil(params: .init(id: incident.id)).makeCall(responseType:Incident.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            completion(response)
            
        } failure: { error in
            self.error = error
            self.toast = error.toast
            completion(nil)
        }
        
    }
    
    func generatePdf(incident: Incident, completion: @escaping (_ completed: Bool) -> ()) {
        DispatchQueue.main.async {
            self.pdfLoading = true
        }
        IncidentRequest
            .generatePdf(params: .init(incidentId: incident.id))
            .makeCall(responseType: IncidentPdfResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                self.pdfLoading = false
                } success: { (response) in
                    self.pdfUrl = response.pdfUrl
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        }
    
    func getShareMessage(incident: Incident) -> String {
        
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
        
        // MARK: - Incident Types
        let incidentTypeTitles = incident.incidentType
            .compactMap { typeId in
                IncidentType.allCases.first { $0.id == typeId }?.title
            }
            .joined(separator: ", ")
        let incidentTypesText = incidentTypeTitles.isEmpty ? "na".localizedString() : incidentTypeTitles
        
        // MARK: - Injured Employees
        let injuredEmployeesText = incident.injuredEmployees?.map { employee in
            let name = safeText(employee.employeeName)
            let code = safeText(employee.employeeCode)
            let companyName = safeText(employee.companyName)
            let profession = safeText(employee.profession)
            
            return """
            \("name".localizedString()) : \(name)
            \("code".localizedString()) : \(code)
            \("company".localizedString().capitalizedFirstLetter) : \(companyName)
            \("profession".localizedString()) : \(profession)
            """
        }.joined(separator: "\n\n") ?? "na".localizedString()
        
        // MARK: - Facility
        let facilityName = safeText(incident.facilities?.groupName, default: "no_facility".localizedString())
        
        // MARK: - Images
        let imageCount = incident.images?.count ?? 0
        let imagesText: String
        if imageCount == 0 {
            imagesText = "no_images".localizedString()
        } else if imageCount == 1 {
            imagesText = "1 " + "image_attached".localizedString()
        } else {
            imagesText = "\(imageCount) " + "images_attached".localizedString()
        }
        
        // MARK: - Date & Time
        let incidentDateText = safeText(
            incident.incidentDate.convertDateFormater(
                dateFormat: "dd-MM-yyyy",
                inputFormat: "yyyy-MM-dd HH:mm:ss",
                local: LocalizationService.shared.language.local
            )
        )
        
        let incidentTimeText = safeText(
            incident.incidentTime.convertDateFormater(
                dateFormat: "HH:mm",
                inputFormat: "HH:mm:ss",
                local: LocalizationService.shared.language.local
            )
        )
        
        // MARK: - Location, Description, Corrections
        let locationText = safeText(incident.incidentLocation)
        let descriptionText = safeText(incident.description)
        let correctionsText = safeText(incident.corrections)
        
        // MARK: - Reported On & By
        let reportedOnText = convertUTCToLocal(utcString: incident.createdAt) ?? "N/A"
        let reportedByText = safeText(incident.reportedBy)
        
        // MARK: - Localized Labels
        let header = "incident_report".localizedString().uppercased()
        let dateLabel = "incident_date".localizedString().uppercased()
        let timeLabel = "incident_time".localizedString().uppercased()
        let typeLabel = "incident_types".localizedString().uppercased()
        let projectLabel = "project".localizedString().uppercased()
        let locationLabel = "location".localizedString().uppercased()
        let injuredLabel = "injured_employees".localizedString().uppercased()
        let descriptionLabel = "description".localizedString().uppercased()
        let correctionsLabel = "corrections".localizedString().uppercased()
        let imagesLabel = "images_small".localizedString().uppercased()
        let reportedOnLabel = "reported_on_small".localizedString().uppercased()
        let reportedByLabel = "reported_by_small".localizedString().uppercased()
        
        // MARK: - Return Final Message (RTL auto-handled)
        return """
        *--- \(header) \(incident.id) ---*
        *\(dateLabel) :* \(incidentDateText)
        *\(timeLabel) :* \(incidentTimeText)
        *\(typeLabel) :* \(incidentTypesText)
        *\(projectLabel) :* \(facilityName)
        *\(locationLabel) :* \(locationText)
        
        *\(injuredLabel) :*
        \(injuredEmployeesText)
        
        *\(descriptionLabel) :*
        \(descriptionText)
        
        *\(correctionsLabel) :*
        \(correctionsText)
        
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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\("QualityExpertise - Incident(\(self.incident?.id ?? -1))").pdf")
            do {
                try data.write(to: tempURL)
                completion(tempURL)
            } catch {
                self.toast = Toast.alert(subTitle: "pdf_save_error".localizedString())
                completion(nil)
            }
        }
    }
    
    func saveAsDraft(id: Int, date: Date?, time: Date?, incidentLocation: String?, incidentType: [Int], injuredEmployees: [Employee], description: String?, corrections: String?, facilities: GroupData?, images: [ImageData]?, reportedBy: String, completion: @escaping (_ completed: Bool) -> ()) {
        
        do {
            let formattedDate = date?.formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            let formattedTime = time?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
            let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            
            
            guard let dateStr = formattedDate, !dateStr.isEmpty,
                  let timeStr = formattedTime, !timeStr.isEmpty else {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
                return
            }
            let incidents = Incident(id: draftIncident?.id ?? -1,
                                     incidentDate: dateStr,
                                     incidentTime: timeStr,
                                     incidentLocation: incidentLocation,
                                     incidentType: incidentType,
                                     injuredEmployees: injuredEmployees,
                                     description: description,
                                     corrections: corrections,
                                     createdAt: createdAt,
                                     facilities: facilities,
                                     images: images,
                                     reportedBy: reportedBy)
            
            try localDBUseCase.saveIncidents([incidents])
            completion(true)
            return
            
        } catch {
            toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
        }
        
        completion(false)
    }
}


extension String {
    var capitalizedFirstLetter: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}

