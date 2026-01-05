//
//  SettingsViewModel.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import SwiftUI

class SettingsViewModel: BaseViewModel, ObservableObject {
    var user = UserManager.getCheckOutUser()!
    var result: SettingsResult?
    
    func upload(image: UIImage?,
                loading: @escaping (Bool) -> (),
                completed: @escaping (String) -> (),
                failure: @escaping () -> ()) {
        
        do {
            guard let image = image else {
                throw SystemError("EVENT_IMAGE".localizedString(), type: .validation)
            }
            
            ImageUploadRequest
                .companyLogo(image: image)
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
    
    func updateCompanyDetails(companyName: String, companyLogo: String, completion: @escaping (_ completed: Bool) -> ()) {
        if user.isGuestUser {
            GuestRequest
                .updateComapnyDetails(params: .init(guestUserId: user.userId, companyLogo: companyLogo, companyName: companyName))
                .makeCall(responseType: GuestRequest.GuestComapnyResponse.self) { (isLoading) in
                    self.showLoader(loading: isLoading)
                } success: { (companyDetails) in
                    var guestUser = self.user
                    guestUser.guestDetails?.company = companyDetails.companyName
                    guestUser.guestDetails?.companyLogo = companyDetails.companyLogo
                    UserManager.saveCheckOutUser(user: guestUser)
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        } else {
            UpdateRequest
                .updateComapnyDetails(params: .init(companyLogo: companyLogo, companyName: companyName))
                .makeCall(responseType: UpdateRequest.CompanyDetailsResponse.self) { (isLoading) in
                    self.showLoader(loading: isLoading)
                } success: { (companyDetails) in
                    var userDetailsData = UserManager.getUserDetails()!
                    userDetailsData.companyName = companyDetails.companyName
                    userDetailsData.companyLogo = companyDetails.companyLogo
                    UserManager.saveUserDetails(userDetails: userDetailsData)
                    completion(true)
                } failure: { (error) in
                    self.toast = error.toast
                }
        }
    }
    
    func userSettings(type: SettingsType, onCompletion: @escaping (_ emailNotificationEnabled: Bool, _ appNotificationEnabled: Bool) -> Void) {
        SettingsRequest
            .settings(params: .init(notificationType: type))
            .makeCall(responseType: SettingsResult.self) { isLoading in
                self.isLoading = isLoading
            } success: { result in
                self.result = result
                let settings = SettingsModel(emailNotification: result.emailNotification, appNotification: result.appNotification)
                UserManager.saveSettings(settings: settings)
                onCompletion(result.emailNotification, result.appNotification)
            } failure: { error in
                self.error = error
                self.toast = error.toast
                onCompletion(self.result?.emailNotification ?? false, self.result?.appNotification ?? false)
            }
    }
}
