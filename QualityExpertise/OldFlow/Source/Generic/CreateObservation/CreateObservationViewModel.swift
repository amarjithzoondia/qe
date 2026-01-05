//
//  CreateObservationViewModel.swift
// ALNASR
//
//  Created by developer on 31/01/22.
//

import SwiftUI

class CreateObservationViewModel: BaseViewModel, ObservableObject {
    let isEditing: Bool
    
    internal init(isEditing: Bool = false) {
        self.isEditing = isEditing
    }
    
    func upload(image: UIImage?,
                loading: @escaping (Bool) -> (),
                completed: @escaping (String) -> (),
                failure: @escaping () -> ()) {
        
        do {
            guard let image = image else {
                throw SystemError("EVENT_IMAGE".localizedString(), type: .validation)
            }
            
            ImageUploadRequest
                .observationImage(image: image)
                .upload(responseType: ImageUploadResponse.self) { (isLoading) in
                    loading(isLoading)
                } success: { (response) in
                    completed(response.imageUrl)
                } failure: { (error) in
                    failure()
                }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
    
    func createObservation(observationTitle: String,
                reportedBy: String,
                location: String,
                description: String,
                groupSpecified: Int,
                groupId: Int,
                notificationTo: [Int],
                responsiblePersonName: String,
                responsiblePerson: Int,
                imageDescription: [ImageData]?,
                customResponsiblePerson: CustomResponsiblePerson,
                responsiblePersonEmail: String,
                completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let observationTitle = try observationTitle.validatedText(validationType: .requiredField(field: "Observation Title".localizedString()))
            
            guard let imageDatas = imageDescription?.filter({$0.image != "" || $0.description != ""}) else {
                return
            }
            
            if let index = imageDatas.firstIndex(where: {($0.image == "" && $0.description != "")}) {
                throw SystemError("Image" + Constants.SPACE +  (index + 1).string + Constants.SPACE + "is missing")
            }
            
            let params = CreateObservationRequest.Params(observationId: -1, observationTitle: observationTitle, reportedBy: reportedBy, location: location, description: description, groupSpecified: groupSpecified, groupId: groupId, notificationTo: notificationTo, responsiblePersonName: responsiblePersonName, responsiblePerson: responsiblePerson, imageDescription: imageDatas, saveAsDraft: false, responsiblePersonEmail: responsiblePersonEmail, customResponsiblePerson: customResponsiblePerson)
            
            ObservationRequest
                .createObservation(params: params)
                .makeCall(responseType: CreateObservationRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
    
    func guestCreateObservation(observationTitle: String,
                reportedBy: String,
                location: String,
                description: String,
                responsiblePerson: String,
                imageDescription: [ImageData]?,
                responsiblePersonEmail: String,
                completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let observationTitle = try observationTitle.validatedText(validationType: .requiredField(field: "Observation Title".localizedString()))
            
            guard let imageDatas = imageDescription?.filter({$0.image != "" || $0.description != ""}) else {
                return
            }
            
            if let index = imageDatas.firstIndex(where: {($0.image == "" && $0.description != "")}) {
                throw SystemError("Image" + Constants.SPACE +  (index + 1).string + Constants.SPACE + "is missing")
            }
            
            let params = CreateObservationRequest.GuestParams(guestUserId: UserManager.getCheckOutUser()?.userId ?? -1, observationTitle: observationTitle, reportedBy: reportedBy, location: location, description: description, responsiblePerson: responsiblePerson, imageDescription: imageDatas, responsiblePersonEmail: responsiblePersonEmail)
            
            GuestRequest
                .createObservation(params: params)
                .makeCall(responseType: CreateObservationRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
}
