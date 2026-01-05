//
//  CreatePreTaskViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 24/10/25.
//

//
import UIKit
import SwiftUI
import CoreData

class CreatePreTaskViewModel: BaseViewModel, ObservableObject {
    
    let draftPreTask: PreTask?
    var preTask: PreTask?
    
    let preTaskId: Int?
    let notificationId: Int?
    @Published var employees: [Employee] = []
    @Published var topics: [PreTaskTopic] = []
    @Published var contents: [PreTaskAPI.Content] = []
    @Published var questions: [PreTaskAPI.Question] = []
    @Published var hasUpdates: Bool = false
    var pdfUrl: String = Constants.EMPTY_STRING
    private let localDBRepository = PreTaskDBRepository()
    private let localDBUseCase: PreTaskDBUseCase
    
    internal init(preTask: PreTask?, draftPreTask: PreTask?, preTaskId: Int?, notificationId: Int?) {
        self.preTask = preTask
        self.draftPreTask = draftPreTask
        self.preTaskId = preTaskId
        self.notificationId = notificationId
        localDBUseCase = PreTaskDBUseCase(repository: localDBRepository)
    }
    
    func buildTopics() {
        topics = contents.compactMap { content in
            let relatedQuestions = questions.filter { $0.contentId == content.id }
            // Only include this topic if it has at least one related question
            guard !relatedQuestions.isEmpty else { return nil }
            return PreTaskTopic(
                id: content.id,
                title: content.title,
                questions: relatedQuestions
            )
        }
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
    
    
    func publish(
        date: Date?,
        startTime: Date?,
        endTime: Date?,
        taskTitle: String,
        msraReference: String?,
        permitReference: String?,
        notes: String?,
        otherTopic: [PreTaskQuestion],
        attendees: [Employee],
        facilities: GroupData?,
        images: [ImageData]?,
        reportedBy: String,
        sendNotificationTo: [UserData]?,
        completion: @escaping (_ completed: Bool) -> ()
    ) {
        let formattedDate = date?.formattedDateString(format: Constants.DateFormat.REPO_DATE)
        let formattedStartTime = startTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
        let formattedEndTime = endTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
        let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)

        // MARK: - Validation
        guard let dateStr = formattedDate, !dateStr.isEmpty,
              let startTimeStr = formattedStartTime, !startTimeStr.isEmpty,
              let endTimeStr = formattedEndTime, !endTimeStr.isEmpty,
              !taskTitle.isEmpty,
              !reportedBy.isEmpty else {
            self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
            completion(false)
            return
        }

        if let start = startTime, let end = endTime {
            let calendar = Calendar.current
            guard
                let startWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: start),
                let endWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: end),
                startWithoutSeconds < endWithoutSeconds
            else {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "end_time_warning".localizedString())
                completion(false)
                return
            }
        }
        
        for question in questions {
            if question.selectedAnswer == nil {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_questions_must_answer".localizedString())
                return
            }
        }
        
        for question in otherTopic {
            if !question.title.isEmpty && question.selectedAnswer == nil {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_questions_must_answer".localizedString())
                return
            }
        }
        
        let validOtherTopics = otherTopic.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        let params = PreTaskParams(
            date: dateStr,
            startTime: startTimeStr,
            endTime: endTimeStr,
            taskTitle: taskTitle,
            msraReference: msraReference,
            permitReference: permitReference,
            contents: self.contents,
            questions: self.questions,
            otherTopic: validOtherTopics,
            attendees: attendees,
            images: images ?? [],
            facilitiesId: facilities?.groupId ?? "",
            notes: notes,
            createdAt: createdAt,
            reportedBy: reportedBy,
            sendNotificationTo: sendNotificationTo?.map { $0.userId }

        )

        PreTaskRequest.create(params: params).makeCall(responseType: PreTaskResponse.self) { isLoading in
            self.isLoading = isLoading
        } success: { [weak self] response in
            guard let self else { return }
            DispatchQueue.main.async {
                if let draftPreTask = self.draftPreTask {
                    do {
                        try self.localDBUseCase.deletePreTask(draftPreTask)
                    } catch {
                        self.toast = "failed_draft_delete".localizedString().infoToast
                    }
                }
                completion(true)
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
            completion(false)
        }
    }

    
    
    
    func fetchPreTaskDetails(completion: @escaping (_ preTask: PreTask?) -> ()) {
        // If no draft, use normal behavior
        guard let draftPreTask else {
            if let id = preTaskId ?? preTask?.id {
                PreTaskRequest.detail(params: .init(id: id))
                    .makeCall(responseType: PreTask.self) { isLoading in
                        self.isLoading = isLoading
                    } success: { response in
                        self.contents = response.contents ?? []
                        self.questions = response.questions ?? []
                        self.preTask = response
                        self.buildTopics()
                        DispatchQueue.main.async { completion(response) }
                    } failure: { error in
                        self.error = error
                        self.toast = error.toast
                        DispatchQueue.main.async { completion(nil) }
                    }
            } else {
                completion(nil)
            }
            return
        }

        // ✅ Draft case
        self.contents = draftPreTask.contents ?? []
        self.questions = draftPreTask.questions ?? []
        self.buildTopics()

        // If offline, just use draft
        guard isConnectedToInternet() else {
            DispatchQueue.main.async { completion(draftPreTask) }
            return
        }

        // ✅ Online: check for newer updates
        PreTaskRequest.contents(params: .init(contentsUpdatedTime: nil, questionsUpdatedTime: nil))
            .makeCall(responseType: PreTaskAPI.TopicsResponse.self) { isLoading in
                self.isLoading = isLoading
            } success: { response in
                let apiContents = response.contents
                let apiQuestions = response.questions
                var hasNewerData = false

                print("\n==============================")
                print("🚀 Pre-Task Data Sync Started")
                print("==============================")

                // --- Handle empty API response ---
                if (apiContents.isEmpty && apiQuestions.isEmpty) &&
                    (!(draftPreTask.contents?.isEmpty ?? true) || !(draftPreTask.questions?.isEmpty ?? true)) {
                    print("⚠️ API returned empty lists while draft has data — marking as updated.")
                    hasNewerData = true
                }

                guard !apiContents.isEmpty || !apiQuestions.isEmpty else {
                    print("📦 API returned no contents or questions — nothing to compare.")
                    DispatchQueue.main.async {
                        self.hasUpdates = hasNewerData
                        print("✅ Sync Complete — No Updates Detected (API Empty)\n")
                        completion(draftPreTask)
                    }
                    return
                }

                // --- Compare Contents ---
                print("\n🆔 Comparing Contents ......")
                for apiContent in apiContents {
                    if let draftContent = draftPreTask.contents?.first(where: { $0.id == apiContent.id }),
                       let draftTime = draftContent.updatedTime,
                       let apiTime = apiContent.updatedTime {
                        print("📄 Draft → \(draftContent.title): ⏰ \(draftTime)")
                        print("🌍 API   → \(apiContent.title): ⏰ \(apiTime)")
                        print(apiTime == draftTime ? "✅ Latest Data" : "⚠️ Needs Update")

                        if apiTime > draftTime {
                            hasNewerData = true
                            print("⬆️ Newer API version found for content → \(apiContent.title)")
                            break
                        }
                    } else {
                        print("🆕 New content found in API → \(apiContent.title)")
                        hasNewerData = true
                        break
                    }
                }

                // --- Compare Questions ---
                if !hasNewerData {
                    print("\n🔍 Comparing Questions ......")
                    for apiQuestion in apiQuestions {
                        if let draftQuestion = draftPreTask.questions?.first(where: { $0.id == apiQuestion.id }),
                           let draftTime = draftQuestion.updatedTime,
                           let apiTime = apiQuestion.updatedTime {
                            print("📄 Draft → \(draftQuestion.title): ⏰ \(draftTime)")
                            print("🌍 API   → \(apiQuestion.title): ⏰ \(apiTime)")
                            print(apiTime == draftTime ? "✅ Latest Data" : "⚠️ Needs Update")

                            if apiTime > draftTime {
                                hasNewerData = true
                                print("⬆️ Newer API version found for question → \(apiQuestion.title)")
                                break
                            }
                        } else {
                            print("🆕 New question found in API → \(apiQuestion.title)")
                            hasNewerData = true
                            break
                        }
                    }
                }
                
                if !hasNewerData {
                    for draftContent in draftPreTask.contents ?? [] {
                        if !apiContents.contains(where: { $0.id == draftContent.id }) {
                            print("🗑️ Content deleted from API → \(draftContent.title)")
                            hasNewerData = true
                            break
                        }
                    }
                }
                
                if !hasNewerData {
                    for draftQuestion in draftPreTask.questions ?? [] {
                        if !apiQuestions.contains(where: { $0.id == draftQuestion.id }) {
                            print("🗑️ Question deleted from API → \(draftQuestion.title)")
                            hasNewerData = true
                            break
                        }
                    }
                }


                // --- Final Summary ---
                print("\n==============================")
                if hasNewerData {
                    print("⚠️ Updates Detected — Local draft needs refresh.")
                } else {
                    print("✅ No Updates — Local draft is up to date.")
                }
                print("==============================\n")

                DispatchQueue.main.async {
                    self.hasUpdates = hasNewerData
                    completion(draftPreTask)
                }

            } failure: { error in
                DispatchQueue.main.async {
                    print("\n❌ Pre-Task Data Sync Failed — \(error.localizedDescription)\n")
                    self.error = error
                    self.toast = error.toast
                    completion(draftPreTask)
                }
            }
    }


    
    func generatePdf(preTask: PreTask, completion: @escaping (_ completed: Bool) -> ()) {
        DispatchQueue.main.async {
            self.pdfLoading = true
        }
        PreTaskRequest
            .generatePdf(params: .init(preTaskId: Int(preTask.id)))
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
    
    func getShareMessage() -> String {
        
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
        
        // MARK: - PreTask check
        guard let preTask = self.preTask else {
            return "no_pre_task_data_available".localizedString()
        }
        
        // MARK: - Topics + Questions
        var topicsText = ""
        for content in self.contents {
            let relatedQuestions = self.questions.filter { $0.contentId == content.id }
            guard !relatedQuestions.isEmpty else { continue }
            
            topicsText += "\n• *\(safeText(content.title))*"
            for question in relatedQuestions {
                let answerText = question.selectedAnswer?.title ?? "-"
                topicsText += "\n   ◦ \(safeText(question.title)) — *\(answerText)*"
            }
        }
        if topicsText.isEmpty { topicsText = "na".localizedString() }
        
        // MARK: - Other Questions
        var otherQuestionText = ""
        if let otherQuestions = preTask.otherTopic, !otherQuestions.isEmpty {
            otherQuestionText += "\n• " + "others_if_any".localizedString()
            for question in otherQuestions {
                let answerText = question.selectedAnswer?.title ?? "-"
                otherQuestionText += "\n   ◦ \(safeText(question.title)) — *\(answerText)*"
            }
        }
        if otherQuestionText.isEmpty { otherQuestionText = "na".localizedString() }
        
        // MARK: - Attendees
        let attendeesText = preTask.attendees?.map { employee in
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
        let facilityName = safeText(preTask.facilities?.groupName, default: "no_facility".localizedString())
        
        // MARK: - Images
        let imageCount = preTask.images?.count ?? 0
        let imagesText: String
        if imageCount == 0 {
            imagesText = "no_images".localizedString()
        } else if imageCount == 1 {
            imagesText = "1 " + "image_attached".localizedString()
        } else {
            imagesText = "\(imageCount) " + "images_attached".localizedString()
        }
        
        // MARK: - Date & Time
        let dateText = preTask.date.convertDateFormater(
            dateFormat: "dd-MM-yyyy",
            inputFormat: "dd-MM-yyyy",
            local: LocalizationService.shared.language.local
        )
        
        let startTimeText = preTask.startTime?.convertDateFormater(
            dateFormat: "HH:mm",
            inputFormat: "HH:mm:ss",
            local: LocalizationService.shared.language.local
        ) ?? ""
        
        let endTimeText = preTask.endTime?.convertDateFormater(
            dateFormat: "HH:mm",
            inputFormat: "HH:mm:ss",
            local: LocalizationService.shared.language.local
        ) ?? ""
        
        // MARK: - Created At
        let createdAtText = convertUTCToLocal(utcString: preTask.createdAt) ?? "N/A"
        let reportedByText = safeText(preTask.reportedBy)
        
        // MARK: - Localized labels
        let header = "pre_task_briefing_report".localizedString().uppercased()
        let dateLabel = "date".localizedString().uppercased()
        let startLabel = "start_time".localizedString().uppercased()
        let endLabel = "end_time".localizedString().uppercased()
        let taskLabel = "task_title".localizedString().uppercased()
        let permitLabel = "permit_reference".localizedString().uppercased()
        let msraLabel = "msra_reference".localizedString().uppercased()
        let topicsLabel = "topics_of_discussion".localizedString().uppercased()
        let otherLabel = "other_questions".localizedString().uppercased()
        let attendeesLabel = "attendes".localizedString().uppercased()
        let projectLabel = "project".localizedString().uppercased()
        let imagesLabel = "images_small".localizedString().uppercased()
        let stepsLabel = "step_by_step_account".localizedString().uppercased()
        let reportedOnLabel = "reported_on_small".localizedString().uppercased()
        let reportedByLabel = "reported_by_small".localizedString().uppercased()
        
        // MARK: - Return message (LTR/RTL auto-handled by system)
        return """
        *--- \(header) \(preTask.id) ---*
        *\(dateLabel) :* \(dateText)
        *\(startLabel) :* \(startTimeText)
        *\(endLabel) :* \(endTimeText)
        *\(taskLabel) :* \(safeText(preTask.taskTitle))
        *\(permitLabel) :* \(safeText(preTask.permitReference))
        *\(msraLabel) :* \(safeText(preTask.msraReference))
        
        *\(topicsLabel) :*
        \(topicsText)
        
        *\(otherLabel) :*
        \(otherQuestionText)
        
        *\(attendeesLabel) :*
        \(attendeesText)
        
        *\(projectLabel) :* \(facilityName)
        *\(imagesLabel) :* \(imagesText)
        *\(stepsLabel) :*
        \(safeText(preTask.notes))
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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\("QualityExpertise - Pre Task Briefing(\(self.preTask?.id ?? -1))").pdf")
            do {
                try data.write(to: tempURL)
                completion(tempURL)
            } catch {
                self.toast = Toast.alert(subTitle: "pdf_save_error".localizedString())
                completion(nil)
            }
        }
    }
    
    func saveAsDraft(
        date: Date?,
        startTime: Date?,
        endTime: Date?,
        taskTitle: String,
        msraReference: String?,
        permitReference: String?,
        notes: String?,
        otherTopic: [PreTaskQuestion],
        attendees: [Employee],
        facilities: GroupData?,
        images: [ImageData]?,
        reportedBy: String,
        sendNotificationTo: [UserData]?,
        completion: @escaping (_ completed: Bool) -> ()
    ) {
        do {
            // MARK: - Format date/time
            let formattedDate = date?.formattedDateString(format: Constants.DateFormat.REPO_DATE)
            let formattedStartTime = startTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
            let formattedEndTime = endTime?.formattedDateString(format: Constants.DateFormat.REPO_TIME)
            let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            
            guard let dateStr = formattedDate, !dateStr.isEmpty,
                  !reportedBy.isEmpty,
                  let startTimeStr = formattedStartTime, !startTimeStr.isEmpty,
                  let endTimeStr = formattedEndTime, !endTimeStr.isEmpty,
                  !taskTitle.isEmpty else {
                self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
                completion(false)
                return
            }
            
            if let start = startTime, let end = endTime {
                let calendar = Calendar.current
                let startWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: start)!
                let endWithoutSeconds = calendar.date(bySetting: .second, value: 0, of: end)!
                if startWithoutSeconds >= endWithoutSeconds {
                    self.toast = Toast.alert(title: "alert".localizedString(), subTitle: "end_time_warning".localizedString())
                    completion(false)
                    return
                }
            }

            let validOtherTopics = otherTopic.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            let preTask = PreTask(
                id: draftPreTask?.id ?? -1,
                date: dateStr,
                startTime: startTimeStr,
                endTime: endTimeStr,
                taskTitle: taskTitle,
                msraReference: msraReference,
                permitReference: permitReference,
                contents: self.contents,
                questions: self.questions,
                otherTopic: validOtherTopics,
                attendees: attendees,
                images: images,
                facilities: facilities,
                notes: notes,
                createdAt: createdAt,
                reportedBy: reportedBy,
                sendNotificationTo: sendNotificationTo
            )
            
            try localDBUseCase.savePreTasks([preTask])
            completion(true)
            
        } catch {
            self.toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
            completion(false)
        }
    }
    
    func getTopics() {
        guard draftPreTask == nil else { return }
//        self.insertDummyData()
        if isConnectedToInternet() {
            self.error = nil
            let params = PreTaskContentsParams(contentsUpdatedTime: nil, questionsUpdatedTime: nil)
            
            PreTaskRequest.contents(params: params).makeCall(responseType: PreTaskAPI.TopicsResponse.self) { [weak self] isLoading in
                DispatchQueue.main.async {
                    self?.isLoading = isLoading
                }
            } success: { [weak self] response in
                guard let self = self else { return }
                
        
                
                DispatchQueue.main.async {
                    self.contents = response.contents
                    self.questions = response.questions
                    self.buildTopics()
                }
                
            } failure: { [weak self] error in
                DispatchQueue.main.async {
                    self?.error = error
                    self?.toast = error.toast
                }
            }
        } else {
            do {
                self.contents = try localDBUseCase.getPreTaskContents()
                self.questions = try localDBUseCase.getPreTaskQuestions()
                self.buildTopics()
            } catch {
                self.error = error as? SystemError
                self.toast = error.toast
            }
        }
    }

    
    func isConnectedToInternet() -> Bool {
        RepositoryManager.Connectivity.isConnected
    }
    
    func insertDummyData() {
        // MARK: - Dummy Contents
        let dummyContents: [PreTaskAPI.Content] = [
            PreTaskAPI.Content(
                id: 1,
                title: "Safety Precautions",
                updatedTime: "2025-10-28 09:00:00",
                order: 1
            ),
            PreTaskAPI.Content(
                id: 2,
                title: "Equipment Check",
                updatedTime: "2025-10-28 09:10:00",
                order: 2
            )
        ]
        
        // MARK: - Dummy Questions
        let dummyQuestions: [PreTaskAPI.Question] = [
            // Content 1 Questions
            PreTaskAPI.Question(
                id: 101,
                contentId: 1,
                title: "Are all safety helmets being worn by team members?",
                imageUrl: "https://www.citypng.com/public/uploads/preview/hd-round-outline-green-tick-mark-symbol-icon-png-701751695051682nfiugbsalz.png?v=2025082716",
                selectedAnswer: .yes,
                updatedTime: "2025-10-28 09:00:00"
            ),
            PreTaskAPI.Question(
                id: 102,
                contentId: 1,
                title: "Is the work area clear of obstacles?",
                imageUrl: "https://www.citypng.com/public/uploads/preview/hd-round-outline-green-tick-mark-symbol-icon-png-701751695051682nfiugbsalz.png?v=2025082716",
                selectedAnswer: .no,
                updatedTime: "2025-10-28 09:05:00"
            ),
            
            // Content 2 Questions
            PreTaskAPI.Question(
                id: 201,
                contentId: 2,
                title: "Are all tools inspected before use?",
                imageUrl: "https://www.citypng.com/public/uploads/preview/hd-round-outline-green-tick-mark-symbol-icon-png-701751695051682nfiugbsalz.png?v=2025082716",
                selectedAnswer: nil,
                updatedTime: "2025-10-28 09:10:00"
            ),
            PreTaskAPI.Question(
                id: 202,
                contentId: 2,
                title: "Is the lifting equipment certified?",
                imageUrl: "https://www.citypng.com/public/uploads/preview/hd-round-outline-green-tick-mark-symbol-icon-png-701751695051682nfiugbsalz.png?v=2025082716",
                selectedAnswer: .yes,
                updatedTime: "2025-10-28 09:15:00"
            )
        ]
        
        // MARK: - Assign to Published Vars
        self.contents = dummyContents
        self.questions = dummyQuestions
        
        // If you have buildTopics() logic, rebuild topics dynamically
        buildTopics()
        
        print("✅ Dummy contents and questions inserted.")
    }
    
    func updateQuestion(_ updatedQuestion: PreTaskAPI.Question) {
        if let index = questions.firstIndex(where: { $0.id == updatedQuestion.id }) {
            questions[index] = updatedQuestion
        }
    }


    
    
}

