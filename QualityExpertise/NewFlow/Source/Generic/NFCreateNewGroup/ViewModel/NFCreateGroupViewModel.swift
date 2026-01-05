//
//  NFCreateGroupViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI

class NFCreateGroupViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var showToast: Bool = false
    @Published var groupDetails: GroupData?
    let isEditing: Bool
    let groupName: String
    let description: String
    let image: String
    let groupCode: String
    
    internal init(isEditing: Bool = false, groupName: String, description: String, image: String, groupCode: String) {
        self.isEditing = isEditing
        self.groupName = groupName
        self.description = description
        self.image = image
        self.groupCode = groupCode
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
                .groupImage(image: image)
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
    
    func createGroup(title: String, description: String, image: String?, completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let title = try title.validatedText(validationType: .requiredField(field: "project_title".localizedString()))
            
            NFGroupRequest
                .createGroup(params: CreateGroupRequest.Params(groupCode: groupCode, groupName: title, description: description, groupImage: image ?? ""))
                .makeCall(responseType: GroupData.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.groupDetails = response
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        } catch {
            DispatchQueue.main.async {
                self.toast = (error as! SystemError).toast
            }
        }
    }
    
    var toast: AlertToast = Toast.alert(subTitle: "") {
        didSet {
            showToast = true
        }
    }
}
