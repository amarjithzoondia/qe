//
//  OTPVerificationContentView.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import SwiftUI

struct OTPVerificationContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: OTPVerificationViewModel
    @State var otp: String = ""
    @State var resendCodeText = "RESEND CODE".localizedString()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Image(IC.LOGO.OTP)
                            
                            Text("Enter Your Code!")
                                .foregroundColor(Color.Grey.DARK_BLUE)
                                .font(.semiBold(17))
                                .padding(.top, 19)
                            
                            Text("OTP has been sent to you on your email")
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.medium(12))
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                            
                            Text(viewModel.email)
                                .foregroundColor(Color.Blue.THEME)
                                .font(.semiBold(16))
                                .padding(.top, 5)
                        }
                        .padding(.top, 41)
                        
                        VStack(spacing: 0) {
                            let width = screenWidth - (57 * 2)
                            OTPInputView(width: width, height: 45.5, pin: $otp, isDeletingAccount: false) { otp, isSuccess  in
                                //isSuccess(true)
                                closeKeyboard()
                            }
                            .padding(.top, 25.5)
                            
                            ButtonWithLoader(action: { onVerify()
                                
                            },
                                             title: "Verify & Proceed".localizedString(),
                                             width: screenWidth - (57 * 2),
                                             height: 41,
                                             isLoading: $viewModel.isLoading)
                                .padding(.top, 22.5)
                            
                            HStack {
                                Text("Didn’t receive the OTP?")
                                    .foregroundColor(Color.Grey.SLATE)
                                    .font(.regular(13))
                                    .padding(.trailing, 2)
                                
                                Button(action: {
                                    resendOtp()
                                }, label: {
                                    Text(resendCodeText)
                                        .foregroundColor(Color.Blue.THEME)
                                        .font(.medium(14))
                                        .onReceive(timer) { _ in
                                            resendCodeText = viewModel.resendCodeTextOnTimerFires()
                                        }
                                })
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 25)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 41)
                }
            }
            .navigationBarTitle("Register", displayMode: .inline)
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            })
            .onAppear {
                resendCodeText = viewModel.resendCodeTextOnTimerFires()
            }
        }
        .pickerViewerOverlay(viewerShown: $viewModel.showAlert, title: "OTP Verification Failed".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Incorrect OTP provided, make sure you enter the correct otp")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(12))
                )
                
                HStack{
                    Button {
                        viewModel.showAlert = false
                        otp = ""
                    } label: {
                        Text("Okay")
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                    }
                    .frame(width: 80, height: 35)
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.top, 10)
                .padding(.trailing, 15)
                .padding(.bottom, 15)
            }
        }
    }
    
    private func onVerify() {
        closeKeyboard()
        viewModel.validateAndVerify(otp: otp) { (completed) in
            otp = ""
            viewControllerHolder?.present(style: .overCurrentContext) {
                HomeScreenView()
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

struct OTPVerificationContentView_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationContentView(viewModel: .init(email: "", tempUserId: -1, resendBalanceDuration: 300.0))
    }
}
