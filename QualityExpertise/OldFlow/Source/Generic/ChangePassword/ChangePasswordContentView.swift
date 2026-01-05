//
//  ChangePasswordContentView.swift
// ALNASR
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
                        
                        Text("Old Password")
                            .font(.regular(12))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        SecureField("Old Password", text: $oldPassword)
                            .font(.medium(15))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                    }
                    
                    VStack(alignment: .leading, spacing: 12.5) {
                        
                        Text("New Password")
                            .font(.regular(12))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        SecureField("New Password", text: $newPassword)
                            .font(.medium(15))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                    }
                    
                    VStack(alignment: .leading, spacing: 12.5) {
                        
                        Text("Confirm New Password")
                            .font(.regular(12))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        SecureField("Confirm New Password", text: $confirmNewPassword)
                            .font(.medium(15))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                    }
                    
                    ButtonWithLoader(action: {
                        onChangePassword()
                    }, title: "Change Password".localizedString(), width: screenWidth - (37 * 2), height: 41, isLoading: $viewModel.isLoading)
                        .padding(.top, 25)

                    
                    Spacer()
                }
                .padding(.horizontal, 37)
                .padding(.top, 21)
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .navigationBarTitle("Change Password".localizedString(), displayMode: .inline)
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

