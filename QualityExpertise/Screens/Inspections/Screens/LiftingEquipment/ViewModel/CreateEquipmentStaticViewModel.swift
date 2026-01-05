//
//  CreateEquipmentStaticViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 04/06/25.
//

import UIKit
import SwiftUICore

class CreateEquipmentStaticViewModel: BaseViewModel, ObservableObject {
    @Published var staticEquipmentData: [EquipmentStatic] = []
    var inspectionID: Int?
    @Published var inspectionView: Inspections?
    var pdfUrl: String = Constants.EMPTY_STRING
    
    internal init(inspectionID:Int? = -1) {
        self.inspectionID = inspectionID
    }
    
    func fetchStaticEquipmentData() {
        StaticEquipmentsRequest.list.makeCall(responseType: [EquipmentStatic].self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.main.async {
                self.staticEquipmentData = response
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }

    }
    
//    func addInspection(inspectionTypeId: Int, modelNumber: String, inspectedBy: String, location: String, description: String, equipmentSource: EquipmentSource?, subContractor: String, staticEquipment: [EquipmentStatic], groupData: GroupData?, notes: String, image: [ImageData], completion: @escaping (_ completed: Bool) -> ()) {
//        
//        do {
//            let inspectionModelNumber = try modelNumber.validatedText(validationType: .requiredField(field: "Model Number".localizedString()))
//            
//            let inspectionDescription = try description.validatedText(validationType: .requiredField(field: "Inspection Description".localizedString()))
//            
//            if equipmentSource == nil {
//                throw SystemError("Required Equipment Source", type: .validation)
//            }
//            
//            if (equipmentSource == .rental || equipmentSource == .subcontractor) && subContractor.isEmpty {
//                throw SystemError("Required If Rental or Subcontractor", type: .validation)
//            }
//            
//            for item in staticEquipment {
//                if item.selectedValue == nil {
//                    throw SystemError("Required \(item.title)", type: .validation)
//                }
//            }
//            
//            InspectionsRequest.addInspection(params: EquipmentStaticParams(auditItemId: inspectionTypeId, modelNumber: inspectionModelNumber, inspectedBy: inspectedBy, location: location, description: inspectionDescription, equipmentSource: equipmentSource, facilities: groupData?.groupId, subContractor: subContractor, staticEquipment: staticEquipment, notes: notes, images: image))
//                .makeCall(responseType: StaticEquipmentResponse.self) { isLoading in
//                    self.isLoading = isLoading
//                } success: { response in
//                    DispatchQueue.main.async {
//                        completion(true)
//                    }
//                } failure: { error in
//                    self.error = error
//                    self.toast = error.toast
//                }
//        } catch {
//            toast = (error as! SystemError).toast
//        }
//
//    }
    
    func addInspection(inspectionTypeId: Int, modelNumber: String, inspectedBy: String, location: String, description: String, equipmentSource: EquipmentSource?, subContractor: String, staticEquipment: [EquipmentStatic], groupData: GroupData?, notes: String, image: [ImageData], completion: @escaping (_ completed: Bool) -> ()) {
        
        var hasValidationError = false
        
        let validatedModelNumber: String? = try? modelNumber.validatedText(validationType: .requiredField(field: "Model Number".localizedString()))
        
        if validatedModelNumber == nil {
            hasValidationError = true
        }
        
        if equipmentSource == nil {
            hasValidationError = true
        }

        if (equipmentSource == .rental || equipmentSource == .subcontractor), subContractor.isEmpty {
            hasValidationError = true
        }

        for item in staticEquipment {
            if item.selectedValue == nil {
                hasValidationError = true
                break
            }
        }

        guard !hasValidationError else {
            toast = Toast.alert(subTitle: "All mandatory fields are required")
            return
        }
        

        InspectionsRequest.addInspection(
            params: EquipmentStaticParams(
                auditItemId: inspectionTypeId,
                modelNumber: validatedModelNumber!,
                inspectedBy: inspectedBy,
                location: location,
                description: description,
                equipmentSource: equipmentSource,
                facilities: groupData?.groupId,
                subContractor: subContractor,
                staticEquipment: staticEquipment,
                notes: notes,
                images: image
            )
        )
        .makeCall(responseType: StaticEquipmentResponse.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.main.async {
                completion(true)
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }
    }
    
    func fetchInspectionDetails() {
        InspectionsRequest.inspectionDeatil(params: .init(id: inspectionID!)).makeCall(responseType:Inspections.self) { isLoading in
            self.isLoading = isLoading
        } success: { response in
            DispatchQueue.main.async {
                self.inspectionView = response
                self.staticEquipmentData = response.staticEquipment ?? []
            }
        } failure: { error in
            self.error = error
            self.toast = error.toast
        }

    }
    
    func generatePdf(completion: @escaping (_ completed: Bool) -> ()) {
        InspectionsRequest
            .generatePdf(params: .init(inspectionId: inspectionID ?? -1))
            .makeCall(responseType: InspectionPdfResponse.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.pdfUrl = response.pdfUrl
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        }
    
    func getShareMessage() -> String {
        return "*---REPORT \(inspectionID ?? -1)---*\n*Title:* \(inspectionView?.auditItem.auditItemTitle ?? "")\n*Inspected By:* \(inspectionView?.inspectedBy ?? "NA")\n*Date Reported:* \(inspectionView?.createdAt.convertDateFormater(dateFormat: "dd MMM yyyy", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") ?? "")\n*Facility:* \((inspectionView?.facilities != nil ? inspectionView?.facilities?.groupName : "No Facility") ?? "No Facility")\n*Location:* \(inspectionView?.location ?? "Not Provided")\n*Description:* \( inspectionView?.description ?? "NA")"
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
}
