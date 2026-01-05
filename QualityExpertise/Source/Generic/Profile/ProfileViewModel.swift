//
//  ProfileViewModel.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import UIKit.UIImage
import SwiftUI

class ProfileViewModel: BaseViewModel, ObservableObject {
    internal init(isEditing: Bool = false) {
        self.isEditing = isEditing
    }
    
    @Published var profile = UserManager().user!
    let isEditing: Bool

    override func refreshData(userInfo: [AnyHashable : Any]?) {
        self.profile = UserManager().user!
    }
    
    func upload(image: UIImage?,
                loading: @escaping (Bool) -> (),
                completed: @escaping (String) -> (),
                failure: @escaping () -> ()) {
        
        do {
            guard let image = image else {
                throw SystemError("image".localizedString(), type: .validation)
            }
            
            ImageUploadRequest
                .profileImage(image: image)
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
    
    func save(name: String,
              imageUrl: String?,
              company: String?,
              designation: String?,
              completed: @escaping (_ user: User) -> ()) {
        do {
            let name = try name.validatedText(validationType: .requiredField(field: "name".localizedString()))
            
            let params = EditProfileRequest.Params(name: name, profileImage: imageUrl ?? "", company: company ?? "", designation: designation ?? "")
                        
            UserRequest
                .editProfile(params: params)
                .makeCall(responseType: User.self) { (isLoading) in
                    self.showLoader(loading: isLoading)
                } success: { (user) in
                    UserManager.saveLogined(user: user)
                    completed(user)
                    NotificationCenter.default.post(name: .UPDATE_PROFILE, object: nil)
                } failure: { (error) in
                    self.toast = error.toast
                }
        } catch {
            toast = (error as! SystemError).toast
        }
    }
}

