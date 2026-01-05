//
//  CreateEquipmentStaticViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

import UIKit
import SwiftUI

final class CreateEquipmentStaticViewModel: BaseViewModel, ObservableObject {
    
    // MARK: - Published Properties
    @Published var staticEquipmentData: [EquipmentStatic] = []
    @Published var inspectionView: Inspections?
    @Published var showAlertForDateChange = false
    
    // MARK: - Properties
    var inspectionID: Int
    var isDateChanged = false
    var pdfUrl: String = Constants.EMPTY_STRING
    
    private let localDBRepository = InspectionDBRepository()
    private let localDBUseCase: InspectionDBUseCase
    
    let draftInspection: Inspections?
    let inspection: Inspections?
    let inspectionTypeID: Int
    
    var cachedUpdatedTime: String?
    var responseUpdatedTime: String?
    
    var cachedFormUpdatedTime: String?
    var responseFormUpdatedAt: String?
    
    // MARK: - Init
    init(
        inspectionID: Int?,
        inspection: Inspections?,
        draftInspection: Inspections?,
        inspectionTypeID: Int
    ) {
        self.inspectionID = inspectionID ?? -1
        self.inspection = inspection
        self.draftInspection = draftInspection
        self.inspectionTypeID = inspectionTypeID
        self.localDBUseCase = InspectionDBUseCase(repository: localDBRepository)
    }
}

// MARK: - Public API
extension CreateEquipmentStaticViewModel {
    
    func fetchStaticEquipmentData() {
        if let draftInspection = draftInspection {
            self.cachedUpdatedTime = draftInspection.lastQuestionsUpdatedAt
            self.cachedFormUpdatedTime = draftInspection.formUpdatedTime
        }
        if isConnectedToInternet() {
            fetchFromAPI {
                if self.draftInspection != nil {
                    self.applyCachedAnswers()
                }
            }
            getAuditsInspectionForms()
        } else {
            loadFromLocalDB()
        }
    }

    
    func getAuditsInspectionForms() {
        var updatedTime: String? = nil
        do {
            updatedTime = try localDBUseCase.getUpdatedAuditItemsDate()
        } catch {
            self.error = error as? SystemError
            self.toast = error.toast
            updatedTime = nil
        }
        InspectionsRequest.auditItems(params: .init(updatedTime: updatedTime)).makeCall(responseType: AuditsInspectionsListResponse.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            if let matchingItem = response.contents.first(where: { $0.auditItemId == self.inspectionTypeID }) {
                let formUpdatedTime = matchingItem.formUpdatedTime
                self.responseFormUpdatedAt = formUpdatedTime
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }

    }
    
    func addInspection(
        inspectionTypeId: Int,
        modelNumber: String,
        inspectedBy: String,
        location: String,
        inspectionDate: Date?,
        description: String,
        equipmentSource: EquipmentSource?,
        subContractor: String,
        staticEquipment: [EquipmentStatic],
        groupData: GroupData?,
        notes: String,
        image: [ImageData],
        isShowingContent: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        
        let formattedDate = inspectionDate?.formattedDateString(format: Constants.DateFormat.REPO_DATE)
        
        
        guard validateInspectionFields(modelNumber: modelNumber, equipmentSource: equipmentSource, subContractor: subContractor, staticEquipment: staticEquipment, inspectionDate: formattedDate, isShowingContent: isShowingContent) else {
            toast = Toast.alert(subTitle: "all_mandatory_fields_required".localizedString())
            return
        }
        
        InspectionsRequest.addInspection(
            params: EquipmentStaticParams(
                auditItemId: inspectionTypeId,
                modelNumber: modelNumber.isEmpty ? nil : modelNumber,
                inspectedBy: inspectedBy,
                location: location,
                inspectionDate: formattedDate,
                description: description,
                equipmentSource: equipmentSource,
                facilities: groupData?.groupId,
                subContractor: subContractor,
                staticEquipment: staticEquipment,
                notes: notes,
                images: image
            )
        )
        .makeCall(responseType: StaticEquipmentResponse.self) { self.isLoading = $0 }
        success: { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if let draft = self.draftInspection {
                    try? self.localDBUseCase.deleteInspection(draft)
                }
                completion(true)
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }
    }
    
    func fetchInspectionDetails(completion: @escaping (Inspections?) -> Void) {
        if let draftInspection {
            completion(draftInspection)
            return
        }
        
        guard inspection != nil else { return }
        
        InspectionsRequest.inspectionDeatil(params: .init(id: inspectionID))
            .makeCall(responseType: Inspections.self) { self.isLoading = $0 }
        success: { response in
            DispatchQueue.main.async {
                completion(response)
                self.inspectionView = response
                self.staticEquipmentData = response.staticEquipment ?? []
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }
    }
    
    func generatePdf(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.pdfLoading = true
        }
        InspectionsRequest.generatePdf(params: .init(inspectionId: inspectionID))
            .makeCall(responseType: InspectionPdfResponse.self) {
                self.isLoading = $0
                self.pdfLoading = false
            }
        success: { response in
            self.pdfUrl = response.pdfUrl
            completion(true)
        } failure: { error in
            self.toast = error.toast
        }
    }
    
    func getShareMessage() -> String {
        // MARK: - Guard
        guard let inspection = inspectionView else {
            return "no_inspection_data_available".localizedString().uppercased()
        }
        
        // MARK: - Helper functions
        func safeText(_ value: String?, default defaultText: String = "na".localizedString()) -> String {
            guard let text = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                return defaultText
            }
            return text
        }
        
        func convertUTCToLocal(utcString: String, inputFormat: String = "yyyy-MM-dd HH:mm:ss.SSSSSSXXXXX") -> String? {
            let formatter = DateFormatter()
            formatter.dateFormat = inputFormat
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            guard let date = formatter.date(from: utcString) else { return nil }
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            return formatter.string(from: date)
        }
        
        
        // MARK: - Determine conditional fields
        let showingIds: Set<Int> = [4, 5, 6, 7, 8]
        let isShowingContent = showingIds.contains(inspection.auditItem.auditItemId)
        
        // MARK: - Basic fields
        let titleText = safeText(inspection.auditItem.auditItemTitle)
        let inspectedByText = safeText(inspection.inspectedBy)
        let modelNumberText = safeText(inspection.modelNumber)
        let inspectionDateText = safeText(inspection.inspectionDate)
        let facilityText = safeText(inspection.facilities?.groupName)
        let locationText = safeText(inspection.location)
        let descriptionText = safeText(inspection.description)
        let notesText = safeText(inspection.notes)
        let subContractorText = safeText(inspection.subContractor)
        let equipmentSourceText = safeText(inspection.equipmentSource?.title)
        
        // MARK: - Equipment list
        let equipmentLines: String = {
            guard let equipments = inspection.staticEquipment, !equipments.isEmpty else {
                return ""
            }
            return equipments.map { equipment in
                let title = safeText(equipment.title)
                let selectedValueText: String
                switch equipment.selectedValue {
                case .yes: selectedValueText = "yes".localizedString()
                case .no: selectedValueText = "no".localizedString()
                case .notApplicable, .none: selectedValueText = "na".localizedString()
                }
                return "\(title): \(selectedValueText)"
            }.joined(separator: "\n")
        }()
        
        // MARK: - Images
        let imageCount = inspection.images?.count ?? 0
        let imagesText: String
        if imageCount == 0 {
            imagesText = "no_images".localizedString()
        } else if imageCount == 1 {
            imagesText = "1 " + "image_attached".localizedString()
        } else {
            imagesText = "\(imageCount) " + "images_attached".localizedString()
        }
        
        // MARK: - Reported On & Reporter
        let reportedOnText = convertUTCToLocal(utcString: inspection.createdAt) ?? "na".localizedString()
        let reportedByText = safeText(inspection.inspectedBy)
        
        // MARK: - Localized Labels
        let header = "audit_inspection_report".localizedString().uppercased()
        let titleLabel = "title".localizedString().uppercased()
        let inspectedByLabel = "inspected_by".localizedString().uppercased()
        let dateLabel = "inspection_date".localizedString().uppercased()
        let projectLabel = "project".localizedString().uppercased()
        let locationLabel = "location".localizedString().uppercased()
        let descriptionLabel = "description".localizedString().uppercased()
        let notesLabel = "notes".localizedString().uppercased()
        let modelNumberLabel = "model_number".localizedString().uppercased()
        let subContractorLabel = "sub_contractor".localizedString().uppercased()
        let equipmentSourceLabel = "equipment_source".localizedString().uppercased()
        let imagesLabel = "images_small".localizedString().uppercased()
        let reportedOnLabel = "reported_on_small".localizedString().uppercased()
        let reportedByLabel = "reported_by_small".localizedString().uppercased()
        let label = "\(titleText) \("fields".localizedString())".uppercased()
        
        // MARK: - Return Final Message (LTR/RTL auto-handled)
        return """
        *--- \(header) \(inspection.id) ---*
        *\(titleLabel) :* \(titleText)
        *\(inspectedByLabel) :* \(inspectedByText)
        *\(dateLabel) :* \(inspectionDateText)
        *\(projectLabel) :* \(facilityText)
        *\(locationLabel) :* \(locationText)
        *\(descriptionLabel) :* \(descriptionText)
        *\(notesLabel) :* \(notesText)
        \(isShowingContent ? """
        *\(modelNumberLabel) :* \(modelNumberText)
        *\(subContractorLabel) :* \(subContractorText)
        *\(equipmentSourceLabel) :* \(equipmentSourceText)
        """ : "")
        
        \(equipmentLines.isEmpty ? "" : "*\(label) :*\n\(equipmentLines)")
        
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
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\("QualityExpertise - Audits & Inspections(\(self.inspection?.id ?? -1))").pdf")
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
        inspectionType: AuditsInspectionsList,
        modelNumber: String,
        inspectedBy: String,
        location: String,
        inspectionDate: Date?,
        description: String,
        equipmentSource: EquipmentSource?,
        subContractor: String,
        staticEquipment: [EquipmentStatic],
        groupData: GroupData?,
        notes: String,
        image: [ImageData],
        isShowingContent: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        let formattedDate = inspectionDate?.formattedDateString(format: Constants.DateFormat.REPO_DATE)

        guard validateInspectionFields(modelNumber: modelNumber, equipmentSource: equipmentSource, subContractor: subContractor, inspectionDate: formattedDate, isShowingContent: isShowingContent) else {
            toast = Toast.alert(subTitle: "all_mandatory_fields_required".localizedString())
            completion(false)
            return
        }
        
        let createdAt = Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
        
        let lastQuestionsUpdatedAt: String?
        if isConnectedToInternet() {
            lastQuestionsUpdatedAt = responseUpdatedTime
        } else {
            do {
                if let draftInspection {
                    lastQuestionsUpdatedAt = draftInspection.lastQuestionsUpdatedAt
                } else {
                    lastQuestionsUpdatedAt = try localDBRepository.getLatestUpdatedTime(inspectionTypeID)
                }
            } catch {
                toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
                lastQuestionsUpdatedAt = nil
            }
        }
        
        let lastFormUpdatedAt: String?
        if isConnectedToInternet() {
            lastFormUpdatedAt = responseFormUpdatedAt
        } else {
            do {
                lastFormUpdatedAt = try localDBRepository.getLatestFormUpdatedTime(inspectionTypeID)
            } catch {
                toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
                lastFormUpdatedAt = nil
            }
        }
        
        
        
        let inspection = Inspections(
            id: Int(draftInspection?.id ?? -1),
            auditItem: inspectionType,
            modelNumber: modelNumber.isEmpty ? nil : modelNumber,
            inspectedBy: inspectedBy,
            location: location,
            inspectionDate: formattedDate,
            description: description,
            equipmentSource: equipmentSource,
            subContractor: subContractor.isEmpty ? nil : subContractor,
            notes: notes,
            createdAt: createdAt,
            facilities: groupData,
            images: image,
            staticEquipment: staticEquipment,
            lastQuestionsUpdatedAt: lastQuestionsUpdatedAt,
            formUpdatedTime: lastFormUpdatedAt
        )
        
        do {
            try localDBUseCase.saveInspections(inspection)
            completion(true)
        } catch {
            toast = (error as? SystemError)?.toast ?? Toast.alert(subTitle: error.localizedDescription)
            completion(false)
        }
    }
    
    func applyCachedAnswers() {
        let formattedCachedUpdatedTime = cachedUpdatedTime?.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
        let formattedResponseUpdatedTime = responseUpdatedTime?.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
  
        let formattedFormUpdatedAt = responseFormUpdatedAt?.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
        let formattedCachedFormUpdatedTime = cachedFormUpdatedTime?.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
        
        
        if formattedResponseUpdatedTime != nil && formattedCachedUpdatedTime != nil &&  formattedCachedUpdatedTime != formattedResponseUpdatedTime && isConnectedToInternet() {
            showAlertForDateChange = true
        }
        
        if formattedFormUpdatedAt != nil && formattedCachedFormUpdatedTime != nil &&  formattedCachedFormUpdatedTime != formattedFormUpdatedAt && isConnectedToInternet() {
            showAlertForDateChange = true
        }
    }
}

// MARK: - Private Helpers
private extension CreateEquipmentStaticViewModel {
    
    func fetchFromAPI(completion: @escaping() -> ()) {
        StaticEquipmentsRequest.list(params: .init(id: inspectionTypeID))
            .makeCall(responseType: EquipmentStaticResponse.self) { isLoading in
                DispatchQueue.main.async {
                    self.isLoading = isLoading
                }
            } success: { response in
                DispatchQueue.main.async {
                    self.responseUpdatedTime = response.updatedTime
                    if self.draftInspection == nil {
                        self.staticEquipmentData = response.contents
                    }
                    completion()
                }
            } failure: { error in
                DispatchQueue.main.async {
                    self.error = error
                    self.toast.subTitle = error.toast.subTitle
                }
            }
    }

    func loadFromLocalDB() {
        do {
            let contents = try localDBUseCase.getContent(inspectionTypeID)
            
            guard !contents.isEmpty else {
                DispatchQueue.main.async {
                    self.staticEquipmentData = []
                }
                return
            }
            
            DispatchQueue.main.async {
                if self.draftInspection == nil {
                    self.staticEquipmentData = contents
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.staticEquipmentData = []
                self.error = SystemError(error.localizedDescription)
                self.toast.subTitle = error.localizedDescription
            }
        }
    }

    
    func isConnectedToInternet() -> Bool {
        RepositoryManager.Connectivity.isConnected
    }
    
    func validateInspectionFields(modelNumber: String, equipmentSource: EquipmentSource?, subContractor: String, staticEquipment: [EquipmentStatic] = [], inspectionDate: String?, isShowingContent: Bool) -> Bool {
        if isShowingContent {
            guard (try? modelNumber.validatedText(validationType: .requiredField(field: "identification_number".localizedString()))) != nil,
                  let source = equipmentSource else { return false }
            
            if (source == .rental || source == .subcontractor), subContractor.isEmpty {
                return false
            }
        }
        
        guard let inspectionDate, !inspectionDate.isEmpty else { return false }

        
        if !staticEquipment.isEmpty, staticEquipment.contains(where: { $0.selectedValue == nil }) {
            return false
        }
        
        return true
    }
}
