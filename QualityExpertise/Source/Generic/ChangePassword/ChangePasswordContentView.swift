//
//  ChangePasswordContentView.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import SwiftUI

struct ChangePasswordContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @StateObject var viewModel = ChangePasswordViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                VStack(spacing: 16.5) {
                    VStack(alignment: .leading, spacing: 12.5) {
                        
                        Text("old_password".localizedString())
                            .font(.regular(12))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        UIKitPasswordField(
                            text: $oldPassword,
                            placeholder: "old_password".localizedString(),
                            isSecure: true,
                            font: .regular(size: 12),
                            textColor: UIColor(Color.Indigo.DARK),
                            placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                            isRTL: LocalizationService.shared.language.isRTLLanguage
                        )
                            .font(.medium(15))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                    }
                    
                    VStack(alignment: .leading, spacing: 12.5) {
                        
                        Text("new_password".localizedString())
                            .font(.regular(12))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        UIKitPasswordField(
                            text: $newPassword,
                            placeholder: "new_password".localizedString(),
                            isSecure: true,
                            font: .regular(size: 12),
                            textColor: UIColor(Color.Indigo.DARK),
                            placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                            isRTL: LocalizationService.shared.language.isRTLLanguage
                        )
                            .font(.medium(15))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                    }
                    
                    VStack(alignment: .leading, spacing: 12.5) {
                        
                        Text("confirm_new_password".localizedString())
                            .font(.regular(12))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        UIKitPasswordField(
                            text: $confirmNewPassword,
                            placeholder: "confirm_new_password".localizedString(),
                            isSecure: true,
                            font: .regular(size: 12),
                            textColor: UIColor(Color.Indigo.DARK),
                            placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                            isRTL: LocalizationService.shared.language.isRTLLanguage
                        )
                            .font(.medium(15))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                    }
                    
                    ButtonWithLoader(action: {
                        onChangePassword()
                    }, title: "change_password".localizedString(), width: screenWidth - (37 * 2), height: 41, isLoading: $viewModel.isLoading)
                        .padding(.top, 25)

                    
                    Spacer()
                }
                .padding(.horizontal, 37)
                .padding(.top, 21)
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .navigationBarTitle("change_password".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .listenToAppNotificationClicks()
        }
    }
    
    func onChangePassword() {
        viewModel.changePassword(old: oldPassword, new: newPassword, confirmNew: confirmNewPassword) {
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
}

struct ChangePasswordContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordContentView()
    }
}

