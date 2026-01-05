//
//  ForgotPasswordContentView.swift
// QualityExpertise
//
//  Created by developer on 21/01/22.
//

import SwiftUI

struct ForgotPasswordContentView: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    @State private var email = ""
    @State private var popUpContentMessage: String? = nil
    @State private var isPopUpShowing: Bool = false
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Image(IC.LOGO.OTP)
                        
                        Text("forgot_password_title".localizedString())
                            .foregroundColor((Color.Indigo.DARK))
                            .font(.semiBold(17))
                            .padding(.top, 19)
                        
                        Text("forgot_password_message".localizedString())
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
                        }, title: "reset_password".localizedString(), width: width, height: 41, isLoading: $viewModel.isLoading)
                            .padding(.top, 22.5)
                            .padding(.bottom, 25)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 41)
                }
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .navigationBarTitle("forgot_password_title".localizedString() ,displayMode: .inline)
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            })
        }
        .pickerViewerOverlay(viewerShown: $isPopUpShowing, title: "success".localizedString()) {
            VStack {
                if let content = popUpContentMessage {
                    LeftAlignedHStack(
                        Text(content)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(14))
                    )
                }
                
                HStack{
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("okay".localizedString())
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                    }
                    .frame(width: 80, height: 35)
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.vertical, 15)
                .padding(.trailing, 15)
            }
        }
    }
    
    func submit() {
        closeKeyboard()
        viewModel.resetPassword(email: email) { completed,message  in
            if completed {
                self.popUpContentMessage = message
                self.isPopUpShowing = true
            }
        }
    }
}

struct ForgotPasswordContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordContentView()
    }
}
