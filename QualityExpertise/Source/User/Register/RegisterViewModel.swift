//
//  RegisterViewModel.swift
// QualityExpertise
//
//  Created by developer on 20/01/22.
//

import SwiftUI
import PhotosUI

class RegisterViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var showToast: Bool = false
    @Published var email: String = ""
    @Published var tempUserId: Int = -1
    
    func upload(image: UIImage?,
                loading: @escaping (Bool) -> (),
                completed: @escaping (String) -> (),
                failure: @escaping () -> ()) {
        
        do {
            guard let image = image else {
                throw SystemError("EVENT_IMAGE".localizedString(), type: .validation)
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
    
    func validateAndRegister(fullName: String, email: String, password: String, confirmPassword: String, image: String?, designation: String?, company: String?, completion: @escaping (_ completed: Bool) -> ()) {
        do {
            let fullName = try fullName.validatedText(validationType: .requiredField(field: "full_name".localizedString()))
            let email = try email.validatedText(validationType: .email)
            let password = try password.validatedText(validationType: .password)
            let confirmPassword = try confirmPassword.validatedText(validationType: .requiredField(field: "confirm_password".localizedString()))
            _ = try confirmPassword.validatedText(validationType: .matchingField(field: "password".localizedString(), with: password))

            UserRequest
                .register(params: RegisterRequest.Params(uuid: UserManager.getCheckOutUser()?.uuid ?? UUID().uuidString, name: fullName, email: email, profileImage: image, designation: designation, company: company, password: password))
                .makeCall(responseType: RegisterRequest.Response.self) { (isLoading) in
                    self.isLoading = isLoading
                } success: { (response) in
                    self.email = response.email
                    self.tempUserId = response.tempUserId
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
