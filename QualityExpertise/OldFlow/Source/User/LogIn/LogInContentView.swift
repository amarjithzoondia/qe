//
//  LogInContentView.swift
// ALNASR
//
//  Created by developer on 19/01/22.
//

import SwiftUI

struct LogInContentView: View {
    
    @StateObject var viewModel = LogInViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isGotoDashBoard = false
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        let frame = geometry.frame(in: .local)
                        scrollContent(in: frame)
                    }
                }
            }
            
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            })
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
        }
    }
    
    fileprivate func sigInButton(in frame: CGRect) -> some View {
        return ButtonWithLoader(action: {
            //TODO: CLICKED SIGNIN
            onSignin()
            
        },
        title: "Login".localizedString(),
        width: frame.width,
        height: 41,
        isLoading: $viewModel.isLoading)
        .padding(.top, 9)
    }
    
    fileprivate func scrollContent(in frame: CGRect) -> some View {
        VStack(spacing: 0) {
            
            Image(IC.LOGO.ABOUT_US)
                .padding(.top, 40.5)
            
            VStack(spacing: 0) {
                Text("Let’s start with Logging in!")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.medium(17))
                
                let frame = CGRect(x: 0, y: 0, width: screenWidth - (46 * 2), height: 0)
                
                VStack(spacing: 11) {
                    EmailInputView(email: $email)
                        .modifier(LoginInputViewModifier(frame: frame))
                    
                    PasswordLoginInputView(password: $password)
                        .modifier(LoginInputViewModifier(frame: frame))
                    
                    sigInButton(in: frame)
                        .padding(.top, 7.5)
                }
                .padding(.top, 36.5)
                
                Button {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ForgotPasswordContentView()
                    }
                } label: {
                    Text("Forgot your password?")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(14))
                }
                .padding(.top, 43)
                
                HStack(spacing: 3) {
                    Text("You don’t have an account?")
                        .foregroundColor(Color.Black.DARK)
                        .font(.light(14))
                        .padding(.trailing, 2)
                    
                    Button {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            RegisterContentView(isFromHome: false)
                        }
                    } label: {
                        Text("Register here")
                            .foregroundColor(Color.Green.DARK_GREEN)
                            .font(.medium(14))
                    }
                }
                .padding(.top, 16)
                
                Button {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                } label: {
                    HStack {
                        Text("Guest User")
                            .foregroundColor(Color.Black.DARK)
                            .font(.medium(13))
                        
                        Image(IC.INDICATORS.BLUE_FORWARD_ARROW)
                            .foregroundColor(Color.Green.DARK_GREEN)
                    }
                    .frame(width: 130, height: 35)
                    .background(Color.white)
                    .cornerRadius(27.5)
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                }
                .padding(.top, 34)
                .padding(.bottom, 20)
                
                if let versionString = Configurations.versionString {
                    Text(versionString)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.light(12))
                        .padding(.bottom, 24)
                }
            }
            .padding(.top, 56)
            .padding(.bottom, 0)
        }
        .padding(.bottom, 20)
        .frame(width: frame.width, alignment: .center)
    }
    
    private func onSignin() {
        closeKeyboard()
        viewModel.validateAndLogin(email: email, password: password) {
            viewControllerHolder?.present(style: .overCurrentContext) {
                HomeScreenView()
            }
        }
    }
}

struct LogInContentView_Previews: PreviewProvider {
    static var previews: some View {
        LogInContentView()
    }
}
