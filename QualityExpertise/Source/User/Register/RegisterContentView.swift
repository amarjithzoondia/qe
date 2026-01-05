//
//  RegisterContentView.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import SwiftUI
import PhotosUI
import SwiftfulLoadingIndicators

struct RegisterContentView: View {
    
    @StateObject var viewModel = RegisterViewModel()
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var imageUrl = Constants.EMPTY_STRING
    @State private var isImagePickFromCamera = false
    @State private var isImagePickFromGallery = false
    @State private var imageUploadStatus = UploadStatus.pending
    @State private var fullName = Constants.EMPTY_STRING
    @State private var email = Constants.EMPTY_STRING
    @State private var password = Constants.EMPTY_STRING
    @State private var confirmPassword = Constants.EMPTY_STRING
    @State private var designation = Constants.EMPTY_STRING
    @State private var company = Constants.EMPTY_STRING
    var isConfirmPassword: Bool = false
    var isFromHome: Bool = false
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack {
                        imageView
                        
                        VStack(spacing: 23) {
                            nameView
                            
                            emailView
                            
                            passwordView
                            
                            confirmPasswordView
                            
                            designationView
                            
                            companyView
                        }
                        .padding(.top, 21)
                        
                        ButtonWithLoader(
                            action: {
                                onSaveAndContinue()
                            },
                            title: "sign_up".localizedString(),
                            width: screenWidth - (2 * 41.5),
                            height: 41,
                            isLoading: $viewModel.isLoading
                        )
                            .padding(.top, 35)
                        
                        HStack(spacing: 5) {
                            Text("already_have_account".localizedString())
                                .foregroundColor(Color.Grey.DARK_BLUE)
                                .font(.light(14))
                            
                            Button {
                                if isFromHome {
                                    viewControllerHolder?.present(style: .overCurrentContext) {
                                        LogInContentView()
                                            .localize()
                                    }
                                } else {
                                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                                }
                                
                            } label: {
                                Text("sign_in".localizedString())
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.medium(14))
                            }
                        }
                        .padding(.top, 21)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 41.5)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                }
            }
            .navigationBarTitle("register".localizedString(), displayMode: .inline)
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
    
    var imageView: some View {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        return ZStack {
            WebUrlImage(url: imageUrl.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                .frame(width: 102, height: 102)
                .cornerRadius(102/2)
                .clipped()
            
            VStack {
                if imageUploadStatus == .inProgress {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                } else {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Group {
                            Button(action: {
                                isImagePickerDisplay.toggle()
                            }, label: {
                                Image(IC.ACTIONS.ADD_PROFILE_IMAGE)
                                    .frame(width: 28.5, height: 28.5, alignment: .center)
                                    .padding(.trailing, 2)
                                    .padding(.bottom, 2)
                            })
                        }
                    }
                }
            }
        }
        .frame(width: 102, height: 102, alignment: .center)
        .actionSheet(isPresented: $isImagePickerDisplay) {
            ActionSheet(title: Text("choose_image".localizedString()), message: Text("select_a_method".localizedString()), buttons: [
                .default(Text("gallery".localizedString())) {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                    ImagePickerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
                        .localize()
                    }
                },
                .default(Text("camera".localizedString())) {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ImagePickerView(selectedImage: $selectedImage, sourceType: .camera)
                            .localize()
                    }
                },
                .cancel()
            ])
        }
        .onChange(of: selectedImage, perform: { value in
            viewModel.upload(image: value) { isLoading in
                imageUploadStatus = .inProgress
            } completed: { url in
                imageUploadStatus = .completed(url: url)
                imageUrl = url
            } failure: {
                imageUploadStatus = .failure
            }
        })
    }
    
    var nameView: some View {
        ThemeTextEditorView(
            text: $fullName,
            title: "full_name".localizedString(),
            disabled: false,
            isMandatoryField: false,
            limit: Constants.Number.Limit.FULLNAME,
        )
    }
    
    var emailView: some View {
        ThemeTextEditorView(
            text: $email,
            title: "email".localizedString(),
            disabled: false,
            isMandatoryField: false,
        )
    }
    
    var passwordView: some View {
        ThemeTextEditorView(text: $password,
                            title: "password".localizedString().uppercased(),
                           disabled: false,
                           isMandatoryField: false,
                           limit: Constants.Number.Limit.PASSWORD,
                           isSecure: true
        )
    }
    
    var confirmPasswordView: some View {
        ThemeTextEditorView(text: $confirmPassword,
                            title: "confirm_password".localizedString().uppercased(),
                           disabled: false,
                           isMandatoryField: false,
                           isSecure: true
        )
    }
    
    var designationView: some View {
        ThemeTextEditorView(text: $designation,
                           title: "designation".localizedString(),
                           disabled: false,
                           isMandatoryField: false,
                           limit: Constants.Number.Limit.DESIGNATION,
        )
    }
    
    var companyView: some View {
        ThemeTextEditorView(text: $company,
                           title: "company".localizedString(),
                           disabled: false,
                           isMandatoryField: false,
                           limit: Constants.Number.Limit.COMPANY,
        )
    }
    
    func onSaveAndContinue() {
        closeKeyboard()
        
        viewModel.validateAndRegister(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword, image: imageUrl, designation: designation, company: company) { (completed) in
            viewControllerHolder?.present(style: .overCurrentContext) {
                OTPVerificationContentView(viewModel: .init(email: viewModel.email, tempUserId: viewModel.tempUserId, resendBalanceDuration: Constants.Number.Duration.OTP_RESEND_TIME_SECONDS))
                    .localize()
            }
        }

    }
}

struct RegisterContentView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterContentView()
    }
}
