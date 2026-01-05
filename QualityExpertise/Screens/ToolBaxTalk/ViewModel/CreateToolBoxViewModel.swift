//
//  CreateToolBoxViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//
import UIKit
import SwiftUI
import CoreData

class CreateToolBoxViewModel: BaseViewModel, ObservableObject {
    
    let draftToolBoxTalk: ToolBoxTalk?
    let toolBoxTalk: ToolBoxTalk?
    @Published var employees: [Employee] = []
    
    var pdfUrl: String = Constants.EMPTY_STRING
    private let localDBRepository = ToolBoxTalkDBRepository()
    private let localDBUseCase: ToolBoxTalkDBUseCase
    
    internal init(toolBoxTalk: ToolBoxTalk?, draftToolBoxTalk: ToolBoxTalk?) {
        self.toolBoxTalk = toolBoxTalk
        self.draftToolBoxTalk = draftToolBoxTalk
        localDBUseCase = ToolBoxTalkDBUseCase(repository: localDBRepository)
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
    
    
    func publish(date: Date?, startTime: Date?, endTime: Date?, topic: String, discussionPoints: [DiscussionPoint], attendantedEmployees: [Employee], facilities: GroupData?, images: [ImageData]?, reportedBy: String, completion: @escaping (Bool) -> ()) {
        
        do {
            let formattedDate = date?.formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            let formattedStartTime = startTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
            
            let formattedEndTime = endTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
            
            let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            
            let validatedDiscussionPoints = discussionPoints.filter { !$0.point.isEmpty }
            
            guard let dateStr = formattedDate, !dateStr.isEmpty, !reportedBy.isEmpty,
                  let startTimeStr = formattedStartTime, !startTimeStr.isEmpty,
                  let endTimeStr = formattedEndTime, !endTimeStr.isEmpty, !topic.isEmpty else {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
                return
            }
            
            if let start = startTime, let end = endTime {
                let calendar = Calendar.current
                
                let startWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: start)!
                let endWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: end)!
                
                if startWithoutSeconds >= endWithoutSeconds {
                    self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "end_time_warning".localizedString())
                    return
                }
            }
            
            
            if validatedDiscussionPoints.isEmpty {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "enter_discussion_to_proceed".localizedString())
                return
            }
            
            if attendantedEmployees.isEmpty {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "enter_employees_to_proceed".localizedString())
                return
            }
            
            let params = ToolBoxParams(
                date: dateStr,
                startTime: startTimeStr,
                endTime: endTimeStr,
                topic: topic,
                discussionPoints: validatedDiscussionPoints,
                attendees: attendantedEmployees,
                createdAt: createdAt,
                facilitiesId: facilities?.groupId,
                images: images,
                reportedBy: reportedBy)
            
            print(params)
            
            ToolBoxRequest.addToolBox(params: params).makeCall(responseType: ToolBoxCreationResponse.self) { isLoading in
                
                self.isLoading = isLoading
                
            } success: { [weak self] response in
                guard let self else { return }
                DispatchQueue.main.async {
                    if let draftToolBoxTalk = self.draftToolBoxTalk {
                        do {
                            try self.localDBUseCase.deleteToolBoxTalk(draftToolBoxTalk)
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
    }
    
    
    func fetchToolBoxDetails(completion: @escaping (_ toolBoxTalk: ToolBoxTalk?) -> ()) {
        if let draftToolBoxTalk {
            completion(draftToolBoxTalk)
            return
        }
        
        guard let toolBoxTalk else {
            completion(nil)
            return
        }
        
        ToolBoxRequest.toolBoxDeatil(params: .init(id: toolBoxTalk.id)).makeCall(responseType:ToolBoxTalk.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            completion(response)
            
        } failure: { error in
            self.error = error
            self.toast = error.toast
            completion(nil)
        }
        
    }
    
    func generatePdf(toolBoxTalk: ToolBoxTalk, completion: @escaping (_ completed: Bool) -> ()) {
        DispatchQueue.main.async {
            self.pdfLoading = true
        }
        ToolBoxRequest
            .generatePdf(params: .init(toolBoxId: toolBoxTalk.id))
            .makeCall(responseType: ToolBoxPdfResponse.self) { (isLoading) in
                self.isLoading = isLoading
                self.pdfLoading = false
            } success: { (response) in
                self.pdfUrl = response.pdfUrl
                completion(true)
            } failure: { (error) in
                self.toast = error.toast
            }
    }
    
    func getShareMessage(toolBox: ToolBoxTalk) -> String {
        
        // MARK: - Helper functions
        func safeText(_ value: String?, default defaultText: String = "N/A") -> String {
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
        
        // MARK: - Discussion Points
        let discussionTitles = toolBox.discussionPoints.map { safeText($0.point) }
        let discussionText = discussionTitles.isEmpty
            ? "na".localizedString()
            : discussionTitles.map { "• \($0)" }.joined(separator: "\n")
        
        // MARK: - Attendees
        let attendeesText = toolBox.attendees?.map { employee in
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
        let facilityName = safeText(toolBox.facilities?.groupName, default: "no_facility".localizedString())
        
        // MARK: - Images
        let imageCount = toolBox.images?.count ?? 0
        let imagesText: String
        if imageCount == 0 {
            imagesText = "no_images".localizedString()
        } else if imageCount == 1 {
            imagesText = "1 " + "image_attached".localizedString()
        } else {
            imagesText = "\(imageCount) " + "images_attached".localizedString()
        }
        
        // MARK: - Date, Time, and Reporter
        let dateText = safeText(toolBox.date.convertDateFormater(
            dateFormat: "dd-MM-yyyy",
            inputFormat: "yyyy-MM-dd HH:mm:ss",
            local: LocalizationService.shared.language.local
        ))
        
        let startTimeText = safeText(toolBox.startTime.convertDateFormater(
            dateFormat: "HH:mm",
            inputFormat: "HH:mm:ss",
            local: LocalizationService.shared.language.local
        ))
        
        let endTimeText = safeText(toolBox.endTime.convertDateFormater(
            dateFormat: "HH:mm",
            inputFormat: "HH:mm:ss",
            local: LocalizationService.shared.language.local
        ))
        
        let createdAtText = convertUTCToLocal(utcString: toolBox.createdAt) ?? "N/A"
        let reportedByText = safeText(toolBox.reportedBy)
        let topicText = safeText(toolBox.topic, default: "na".localizedString())
        
        // MARK: - Localized labels
        let header = "toolbox_talk_report".localizedString().uppercased()
        let dateLabel = "date".localizedString().uppercased()
        let startTimeLabel = "start_time".localizedString().uppercased()
        let endTimeLabel = "end_time".localizedString().uppercased()
        let topicLabel = "topic".localizedString().uppercased()
        let discussionLabel = "discussion_points".localizedString().uppercased()
        let attendeesLabel = "attendes".localizedString().uppercased()
        let projectLabel = "project".localizedString().uppercased()
        let imagesLabel = "images_small".localizedString().uppercased()
        let reportedOnLabel = "reported_on_small".localizedString().uppercased()
        let reportedByLabel = "reported_by_small".localizedString().uppercased()
        
        // MARK: - Return final message (RTL auto-handled)
        return """
        *--- \(header) \(toolBox.id) ---*
        *\(dateLabel) :* \(dateText)
        *\(startTimeLabel) :* \(startTimeText)
        *\(endTimeLabel) :* \(endTimeText)
        *\(topicLabel) :* \(topicText)
        *\(discussionLabel) :*
        \(discussionText)
        
        *\(attendeesLabel) :*
        \(attendeesText)
        
        *\(projectLabel) :* \(facilityName)
        *\(imagesLabel) :* \(imagesText)
        *\(reportedOnLabel) :* \(createdAtText)
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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\("QualityExpertise - ToolBox Talks(\(self.toolBoxTalk?.id ?? -1))").pdf")
            do {
                try data.write(to: tempURL)
                completion(tempURL)
            } catch {
                self.toast = Toast.alert(subTitle: "pdf_save_error".localizedString())
                completion(nil)
            }
        }
    }
    
    func saveAsDraft(date: Date?, startTime: Date?, endTime: Date?, topic: String, discussionPoints: [DiscussionPoint], attendantedEmployees: [Employee], facilities: GroupData?, images: [ImageData]?, reportedBy: String, completion: @escaping (_ completed: Bool) -> ()) {
        
        do {
            let formattedDate = date?.formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            let formattedStartTime = startTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
            
            let formattedEndTime = endTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
            
            let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            
            let validatedDiscussionPoints = discussionPoints.filter { !$0.point.isEmpty }
            
            guard let dateStr = formattedDate, !dateStr.isEmpty,
                  !reportedBy.isEmpty,
                  let startTimeStr = formattedStartTime, !startTimeStr.isEmpty,
                  let endTimeStr = formattedEndTime, !endTimeStr.isEmpty, !topic.isEmpty else {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
                return
            }
            
            if let start = startTime, let end = endTime {
                let calendar = Calendar.current
                
                let startWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: start)!
                let endWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: end)!
                
                if startWithoutSeconds >= endWithoutSeconds {
                    self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "end_time_warning".localizedString())
                    return
                }
            }
            
            
            let toolBoxTalk = ToolBoxTalk(
                id: draftToolBoxTalk?.id ?? -1,
                date: dateStr,
                startTime: startTimeStr,
                endTime: endTimeStr,
                topic: topic,
                discussionPoints: validatedDiscussionPoints,
                attendees: attendantedEmployees,
                createdAt: createdAt,
                facilities: facilities,
                images: images,
                reportedBy: reportedBy)
            
            try localDBUseCase.saveToolBoxTalks([toolBoxTalk])
            completion(true)
            return
            
        } catch {
            toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
        }
        
        completion(false)
    }
    
    
}

