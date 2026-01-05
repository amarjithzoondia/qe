//
//  CloseObservationContentView.swift
// QualityExpertise
//
//  Created by developer on 24/02/22.
//

import Foundation

class CloseObservationViewModel: BaseViewModel, ObservableObject {
    var observationId: Int
    var observationTitle: String?
    var observationDescription: String?
    var groupImage: String?
    var groupName: String?
    var groupCode: String?
    var imageDescription: [ImageData]?
    var groupSpecified: Bool
    
    internal init(observationId: Int, observationTitle: String?, observationDescription: String?, groupImage: String? = "", groupName: String? = "", groupCode: String? = "", imageDescription: [ImageData]?, groupSpecified: Bool) {
        self.observationId = observationId
        self.observationTitle = observationTitle
        self.observationDescription = observationDescription
        self.groupImage = groupImage
        self.groupName = groupName
        self.groupCode = groupCode
        self.imageDescription = imageDescription
        self.groupSpecified = groupSpecified
    }
    
    var images: [String]? {
        imageDescription?.map({$0.image ?? ""})
    }
    
    func closeObservation(description: String, imageDescription: [ImageData]?, completion: @escaping () -> ()) {
        do {
            let closeOutDescription = try description.validatedText(validationType: .requiredField(field: "closeout_description".localizedString()))
            
            guard let imageDatas = imageDescription?.filter({$0.image != "" || $0.description != ""}) else {
                return
            }
            
            if let index = imageDatas.firstIndex(where: {($0.image == "" && $0.description != "")}) {
                throw SystemError("image".localizedString() + Constants.SPACE +  (index + 1).string + Constants.SPACE + "is_missing".localizedString())
            }
            
            if UserManager.getCheckOutUser()?.isGuestUser ?? false {
                GuestRequest
                    .closeObservation(params: .init(guestUserId: UserManager.getCheckOutUser()?.userId ?? -1, observationId: observationId, description: closeOutDescription, imageDescription: imageDatas))
                    .makeCall(responseType: CloseObservationRequest.Response.self) { (isLoading) in
                        self.isLoading = isLoading
                    } success: { (response) in
                        completion()
                    } failure: { (error) in
                        self.error = error
                        self.toast = error.toast
                    }
            } else {
               ObservationRequest
                    .closeObservation(params: .init(observationId: observationId, description: closeOutDescription, imageDescription: imageDescription))
                    .makeCall(responseType: CloseObservationRequest.Response.self) { (isLoading) in
                        self.isLoading = isLoading
                    } success: { (response) in
                        completion()
                    } failure: { (error) in
                        self.error = error
                        self.toast = error.toast
                    }
            }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
    
    func fetchObservationDetails() {
        ObservationRequest
            .closeform(params: .init(observationId: observationId))
            .makeCall(responseType: CloseFormResponse.self) { (isLoading) in
                self.isLoading = isLoading
            } success: { (response) in
                self.observationTitle = response.title
                self.observationDescription = response.title
                self.groupName = response.group?.groupName
                self.groupImage = response.group?.groupImage
                self.groupCode = response.group?.groupCode
                self.imageDescription = response.imageDescription
                self.groupSpecified = response.groupSpecified ?? false
            } failure: { (error) in
                self.error = error
                self.toast = error.toast
            }

    }
}
