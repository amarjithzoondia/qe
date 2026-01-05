//
//  CreateLessonLearnedViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 18/07/25.
//


import UIKit
import SwiftUI
import CoreData

class CreateLessonLearnedViewModel: BaseViewModel, ObservableObject {
    
    let draftLesson: LessonLearned?
    let lesson: LessonLearned?
    
    var pdfUrl: String = Constants.EMPTY_STRING
    private let localDBRepository = LessonLearnedDBRepository()
    private let localDBUseCase: LessonLearnedDBUseCase
    
    internal init(lesson: LessonLearned?, draftLesson: LessonLearned?) {
        self.lesson = lesson
        self.draftLesson = draftLesson
        localDBUseCase = LessonLearnedDBUseCase(repository: localDBRepository)
    }
    
    func publish(title: String, description: String, groupData: GroupData?, image: [ImageData], reportedBy: String, completion: @escaping (_ completed: Bool) -> ()) {
        
        var validatedTitle: String?
        
        do {
            validatedTitle = try title.validatedText(validationType: .requiredField(field: "title".localizedString()))
        } catch {
            toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
            return
        }

        let params = LessonLearnedParams(
            facilitiesId: groupData?.groupId,
            title: validatedTitle!,
            description: description,
            images: image,
            reportedBy: reportedBy
        )

        LessonLearnedRequest.addlessonLearned(params: params).makeCall(responseType: LessonLearnedCreationResponse.self) { isLoading in
            self.isLoading = isLoading
        } success: { [weak self] response in
            guard let self else { return }
            DispatchQueue.main.async {
                if let draftLesson = self.draftLesson {
                    do {
                        try self.localDBUseCase.deleteLesson(draftLesson)
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

    
    func fetchViolationDetails(completion: @escaping (_ lesson: LessonLearned?) -> ()) {
        if let draftLesson {
            completion(draftLesson)
            return
        }
          
        guard let lesson else {
            return
        }
        
        LessonLearnedRequest.lessonLearnedDeatil(params: .init(id: lesson.id)).makeCall(responseType:LessonLearned.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            completion(response)
            
        } failure: { error in
            self.error = error
            self.toast = error.toast
            completion(nil)
        }
    }
    
    func generatePdf(lesson: LessonLearned, completion: @escaping (_ completed: Bool) -> ()) {
        DispatchQueue.main.async {
            self.pdfLoading = true
        }
        LessonLearnedRequest
            .generatePdf(params: .init(lessonId: lesson.id))
            .makeCall(responseType: LessonLearnedPdfResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                self.pdfLoading = false
                } success: { (response) in
                    self.pdfUrl = response.pdfUrl
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        }
    
    func getShareMessage(lesson: LessonLearned) -> String {
        
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
        
        // MARK: - Facility name
        let facilityName = safeText(lesson.facilities?.groupName, default: "na".localizedString())
        
        // MARK: - Description
        let descriptionText = safeText(lesson.description, default: "na".localizedString())
        
        // MARK: - Title
        let titleText = safeText(lesson.title, default: "na".localizedString())
        
        // MARK: - Images (smart plural handling)
        let imageCount = lesson.images?.count ?? 0
        let imagesText: String
        if imageCount == 0 {
            imagesText = "no_images".localizedString()
        } else if imageCount == 1 {
            imagesText = "1 " + "image_attached".localizedString()
        } else {
            imagesText = "\(imageCount) " + "images_attached".localizedString()
        }
        
        // MARK: - Date & Reporter
        let reportedOnText = convertUTCToLocal(utcString: lesson.createdAt) ?? "N/A"
        let reportedByText = safeText(lesson.reportedBy)
        
        // MARK: - Localized labels
        let header = "lesson_learned_report".localizedString().uppercased()
        let titleLabel = "title".localizedString().uppercased()
        let projectLabel = "project".localizedString().uppercased()
        let descriptionLabel = "description".localizedString().uppercased()
        let imagesLabel = "images_small".localizedString().uppercased()
        let reportedOnLabel = "reported_on_small".localizedString().uppercased()
        let reportedByLabel = "reported_by_small".localizedString().uppercased()
        
        // MARK: - Message (LTR/RTL handled automatically by WhatsApp)
        return """
        *--- \(header) \(lesson.id) ---*
        *\(titleLabel) :* \(titleText)
        *\(projectLabel) :* \(facilityName)
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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\("QualityExpertise - Lesson Learned(\(self.lesson?.id ?? -1))").pdf")
            do {
                try data.write(to: tempURL)
                completion(tempURL)
            } catch {
                self.toast = Toast.alert(subTitle: "pdf_save_error".localizedString())
                completion(nil)
            }
        }
    }
    
    func saveAsDraft(title: String, description: String, groupData: GroupData?, image: [ImageData], reportedBy: String, completion: @escaping (_ completed: Bool) -> ()) {
        
        do {
            let validatedTitle = try title.validatedText(validationType: .requiredField(field: "title".localizedString()))
            let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            //-1 for new items, id will be autoincrement before saving
            let lesson = LessonLearned(
                id: draftLesson?.id ?? -1,
                title: validatedTitle,
                description: description,
                createdAt: createdAt,
                facilities: groupData,
                images: image,
                reportedBy: reportedBy
            )
            try localDBUseCase.saveLessons([lesson])
            completion(true)
            return
            
        } catch {
            toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
        }
        
        completion(false)
    }
}
