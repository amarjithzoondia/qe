//
//  DeleteAccountContentView.swift
// ALNASR
//
//  Created by Developer on 21/07/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct DeleteAccountContentView: View {
    
    @State var password: String = ""
    @State var otp = ""
    @StateObject var viewModel = DeleteAccountViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var showConfirmationAlert = false
    @State var resendCodeText = "Resend Code"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack {
                    if let error = viewModel.error {
                        error.viewRetry {
                            viewModel.fetchTerms()
                        }
                    } else if viewModel.isLoading {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    } else {
                        ScrollView {
                            
                            VStack(alignment: .center, spacing: 0) {
                                Image(IC.LOGO.SUCCESS)
                                    .frame(width: 175, height: 181.5, alignment: .center)
                                
                                Text("Delete Account")
                                    .font(.semiBold(17))
                                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                    .padding(.top, 59.5)
                                
                                Text(viewModel.deletionMessage)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.light(12))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.Blue.BLUE_GREY)
                                    .padding(.top, 25)
                                    .padding(.bottom, 18.5)
                                
                                if !viewModel.isGuestUser {
                                    
                                    ZStack {
                                        VStack(alignment: .center, spacing: 0) {
                                            
                                            HStack {
                                                Image(IC.PLACEHOLDER.PASSWORD)
                                                    .padding(.leading, 18.5)
                                                
                                                SecureField("", text: $password)
                                                    .modifier(TextFieldInputViewStyle(placeholder: "Password".localizedString(), text: $password))
                                                    .font(.regular(12))
                                                
                                                ButtonWithLoader(action: {
                                                    viewModel.verifyPassword(password: password)
                                                }, title: "", width: 29.5, height: 29.5, image: IC.LOGO.SEND_BLUE,isLoading:  $viewModel.isActionsLoading)
                                                    .padding(.horizontal, 10.5)
                                                    .padding(.vertical, 5)
                                            }
                                            .modifier(LoginInputViewModifier(frame: CGRect(x: 0, y: 0, width: screenWidth - (46 * 2), height: 0)))
                                        }
                                        
                                        if viewModel.deletionContent != nil {
                                            Color.white
                                                .opacity(0.7)
                                        }
                                    }
                                    
                                    if viewModel.deletionContent != nil {
                                        
                                        Text("Enter the OTP sent to your email")    .font(.light(12))  .foregroundColor(Color.Blue.BLUE_GREY)
                                            .padding(.top, 20)
                                        
                                        
                                        Text(UserManager().user?.email ?? "")
                                            .foregroundColor(Color.Blue.THEME)
                                            .font(.regular(12))
                                            .padding(.bottom, 10)
                                        
                                        HStack(alignment: .center) {
                                            OTPInputView(width: screenWidth - (46 * 2), height: 45.5, pin: $otp, isDeletingAccount: true) { otp, isSuccess  in
                                                closeKeyboard()
                                            }
                                        }
                                        .modifier(LoginInputViewModifier(frame: CGRect(x: 0, y: 0, width: screenWidth - (46 * 2), height: 0)))
                                        
                                        HStack(spacing: 0) {
                                            Text("Didn’t receive the OTP? ")
                                                .foregroundColor(Color.Grey.GUNMENTAL)
                                                .font(.light(13))
                                            
                                            
                                            ButtonWithLoader(action: {
                                                resendOtp()
                                            },
                                                             title: resendCodeText,
                                                             titleColor: Color.Grey.GUNMENTAL,
                                                             width: 90,
                                                             height: 25,
                                                             backgroundColor: .clear,
                                                             font: .semiBold(13),
                                                             strokeWidth: 1,
                                                             strokeColor: Color.Grey.GUNMENTAL,
                                                             loadingColor: .clear,
                                                             isLoading: $viewModel.isResendLoading).onReceive(timer) { _ in
                                                resendCodeText =  viewModel.resendCodeTextOnTimerFires()
                                            }
                                                             .disabled(!viewModel.isResendButtonActive)
                                        }
                                        .padding(.top, 12)
                                        .padding(.bottom, 14.5)
                                        
                                        ButtonWithLoader(action: {
                                            showConfirmationAlert.toggle()
                                        }, title: "Submit", titleColor: .white, width: screenWidth  - (46 * 2), height: 45, backgroundColor: Color.Blue.THEME, isLoading: $viewModel.isButtonLoading)
                                    }
                                } else {
                                    ButtonWithLoader(action: {
                                        showConfirmationAlert.toggle()
                                    }, title: "Confirm", titleColor: .white, width: screenWidth  - (46 * 2), height: 45, backgroundColor: Color.Blue.THEME, isLoading: $viewModel.isButtonLoading)
                                }
                            }
                            .padding(.horizontal, 46)
                            .padding(.top, 34.5)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .onAppear(perform: {
                viewModel.fetchTerms()
                resendCodeText = viewModel.resendCodeTextOnTimerFires()
            })
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
        }
        .overlay(DeletionSuccessView(deletionResponse: $viewModel.verifyDeleteResponse))
        .disabled(viewModel.isActionsLoading || viewModel.isButtonLoading || viewModel.isResendLoading)
        .pickerViewerOverlay(viewerShown: $showConfirmationAlert, title: "Confirm Deletion!".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Are you sure you want to delete your account permenantly.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        showConfirmationAlert.toggle()
                    } label: {
                        Text("No")
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        showConfirmationAlert.toggle()
                        viewModel.verifyDelete(otp: otp, completion: { isSuccess in
                            if isSuccess {
                                UserManager.logout(gotoLoginScreen: false)
                            }
                        })
                    } label: {
                        Text("Yes")
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)
            }
        }
    }
    private func resendOtp() {
        viewModel.resendOtp { (completed) in
            otp = ""
            guard completed else { return }
            resendCodeText = viewModel.resendCodeTextOnTimerFires()
        }
    }
}

struct DeleteAccountContentView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountContentView()
    }
}
