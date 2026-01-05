//
//  ForgotPasswordContentView.swift
// ALNASR
//
//  Created by developer on 21/01/22.
//

import SwiftUI

struct ForgotPasswordContentView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    @State private var email = ""
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Image(IC.LOGO.OTP)
                        
                        Text("Forgot Password")
                            .foregroundColor((Color.Indigo.DARK))
                            .font(.semiBold(17))
                            .padding(.top, 19)
                        
                        Text("Enter your email address below to reset password")
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(12))
                            .padding(.top, 10)
                        
                        let width = screenWidth - (45 * 2)
                        EmailInputView(email: $email)
                            .frame(width: width, height: 41)
                            .background(Color.Grey.PALE)
                            .cornerRadius(20.5)
                            .padding(.top, 28.5)
                        
                        ButtonWithLoader(action: {
                            submit()
                        }, title: "Reset Password".localizedString(), width: width, height: 41, isLoading: $viewModel.isLoading)
                            .padding(.top, 22.5)
                            .padding(.bottom, 25)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 41)
                }
            }
            .navigationBarTitle("Forgot Password",displayMode: .inline)
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    func submit() {
        closeKeyboard()
        viewModel.resetPassword(email: email) { completed in
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
}

struct ForgotPasswordContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordContentView()
    }
}
