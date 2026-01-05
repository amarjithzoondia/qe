//
//  NFCreateObservationViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI

class NFCreateObservationViewModel: BaseViewModel, ObservableObject {
    let isEditing: Bool
    private let localDBRepository = ObservationDBRepository()
    private let localDBUseCase: ObservationDBUseCase
    
    internal init(isEditing: Bool = false) {
        self.isEditing = isEditing
        localDBUseCase = ObservationDBUseCase(repository: localDBRepository)
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
    
    func createObservation(observationId: Int,
                observationTitle: String,
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
            let observationTitle = try observationTitle.validatedText(validationType: .requiredField(field: "observation_title".localizedString()))
            
            guard let imageDatas = imageDescription?.filter({$0.image != "" || $0.description != ""}) else {
                return
            }
            
            if let index = imageDatas.firstIndex(where: {($0.image == "" && $0.description != "")}) {
                throw SystemError("image".localizedString() + Constants.SPACE +  (index + 1).string + Constants.SPACE + "is_missing".localizedString())
            }
            
            let params: CreateObservationRequest.Params
            if isEditing {
                params = CreateObservationRequest.Params(observationId: observationId, observationTitle: observationTitle, reportedBy: reportedBy, location: location, description: description, groupSpecified: groupSpecified, groupId: groupId, notificationTo: notificationTo, responsiblePersonName: responsiblePersonName, responsiblePerson: responsiblePerson, imageDescription: imageDatas, saveAsDraft: false, responsiblePersonEmail: responsiblePersonEmail, customResponsiblePerson: customResponsiblePerson)
            } else {
                params = CreateObservationRequest.Params(observationId: -1, observationTitle: observationTitle, reportedBy: reportedBy, location: location, description: description, groupSpecified: groupSpecified, groupId: groupId, notificationTo: notificationTo, responsiblePersonName: responsiblePersonName, responsiblePerson: responsiblePerson, imageDescription: imageDatas, saveAsDraft: false, responsiblePersonEmail: responsiblePersonEmail, customResponsiblePerson: customResponsiblePerson)
            }
            
            NFObservationsRequest
                .createObservation(params: params)
                .makeCall(responseType: CreateObservationRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    if self.isEditing {
                        do {
                            try self.localDBUseCase.deleteObservation(observationId)
                            completion(true)
                            return
                        } catch {
                            self.toast = error.toast
                            return
                        }
                    }
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
            let observationTitle = try observationTitle.validatedText(validationType: .requiredField(field: "observation_title".localizedString()))
            
            guard let imageDatas = imageDescription?.filter({$0.image != "" || $0.description != ""}) else {
                return
            }
            
            if let index = imageDatas.firstIndex(where: {($0.image == "" && $0.description != "")}) {
                throw SystemError("image".localizedString() + Constants.SPACE +  (index + 1).string + Constants.SPACE + "is_missing".localizedString())
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
    
    func createDraftObservation(
        data: NFObservationDraftData,
        completion: @escaping (_ completed: Bool) -> ()
    ) {
        print(data)

        do {
            _ = try data.observationTitle.validatedText(
                validationType: .requiredField(
                    field: "observation_title".localizedString()
                )
            )
            try localDBRepository.save(data)
            completion(true)
            return

        } catch {
            toast = (error as? SystemError)?.toast
                ?? Toast.alert(subTitle: error.localizedDescription)
            completion(false)
            return
        }
    }

}
