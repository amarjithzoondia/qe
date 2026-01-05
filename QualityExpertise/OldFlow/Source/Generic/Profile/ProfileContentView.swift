//
//  ProfileContentView.swift
// ALNASR
//
//  Created by developer on 09/02/22.
//

import SwiftUI
import PhotosUI
import SwiftfulLoadingIndicators

struct ProfileContentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    @StateObject var viewModel: ProfileViewModel
    
    @State private var name = Constants.EMPTY_STRING
    @State private var email = Constants.EMPTY_STRING
    @State private var designation = Constants.EMPTY_STRING
    @State private var company = Constants.EMPTY_STRING
    
    @State private var imageUploadStatus = UploadStatus.pending
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var imageUrl = Constants.EMPTY_STRING
    @State private var isImagePickFromCamera = false
    @State private var isImagePickFromGallery = false
    let updateProfilePublisher = NotificationCenter.default.publisher(for: .UPDATE_PROFILE)
    @State private var showProfileImage = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 46) {

                        imageView

                        VStack(spacing: 25) {
                            nameView
                            
                            emailView
                            
                            designationView
                            
                            companyView
                            
                            changePasswordView
                                .padding(.top, 4)
                        }
                        
                        if viewModel.isEditing {
                            submitView
                        }
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 40)
                }
            }
            .imageViewerOverlay(viewerShown: $showProfileImage, images: [imageUrl])
            .navigationBarTitle(viewModel.isEditing ? "Edit Profile".localizedString() : "My Profile".localizedString(), displayMode: .inline)
            .onAppear {
                setValues()
            }
            .navigationBarItems(
                trailing: viewModel.isEditing ? nil : Button(action: {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ProfileContentView(viewModel: .init(isEditing: true))
                    }
                }, label: {
                    Image(IC.ACTIONS.EDIT_BLACK)
                })
            )
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            })
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .alert(isPresented: $viewModel.showAlert, content: { () -> Alert in
                viewModel.alert
            })
            .toast(isPresenting: $viewModel.isActionsLoading) {
                viewModel.loader
            }
            .onReceive(updateProfilePublisher) { (output) in
                viewModel.refreshData(userInfo: output.userInfo)
                setValues()
            }
            .listenToAppNotificationClicks()
        }
    }
    
    var imageView: some View {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        return ZStack {
            WebUrlImage(url: imageUrl.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                .cornerRadius(102/2)
                .onTapGesture {
                    if !viewModel.isEditing && imageUrl != "" {
                        showProfileImage.toggle()
                    }
                }
            
            if viewModel.isEditing {
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
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 10)
                                })
                            }
                        }
                    }
                }
            }

        }
        .frame(width: 102, height: 102, alignment: .center)
        .actionSheet(isPresented: $isImagePickerDisplay) {
            ActionSheet(title: Text("Choose Image".localizedString()), message: Text("Select a method".localizedString()), buttons: [
                .default(Text("Gallery".localizedString())) {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                    ImagePickerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
                        .localize()
                    }
                },
                .default(Text("Camera".localizedString())) {
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
        ThemeTextFieldView(
            text: $name,
            title: "Name".localizedString(),
            disabled: !viewModel.isEditing,
            isMandatoryField: false
        )
    }
    
    var emailView: some View {
        ThemeTextFieldView(
            text: $email,
            title: "Email".localizedString(),
            disabled: true,
            placeholder: UserManager.getLoginedUser()?.email,
            isMandatoryField: false
        )
    }
    
    var designationView: some View {
        ThemeTextFieldView(
            text: $designation,
            title: "Designation".localizedString(),
            disabled: !viewModel.isEditing,
            keyboardType: .asciiCapable,
            isMandatoryField: false,
            autocapitalizationType: .words
        )
    }
    
    var companyView: some View {
        ThemeTextFieldView(
            text: $company,
            title: "Company Name".localizedString(),
            disabled: !viewModel.isEditing,
            keyboardType: .asciiCapable,
            isMandatoryField: false,
            autocapitalizationType: .words
        )
    }
    
    var changePasswordView: some View {
        Button(action: {
            viewControllerHolder?.present(style: .overCurrentContext) {
                ChangePasswordContentView()
            }
        }, label: {
            HStack(spacing: 0) {
                Text("Change Your Password")
                    .foregroundColor(Color.Blue.THEME)
                    .font(.medium(13))
                
                Spacer()
                
                Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                    .foregroundColor(Color.Blue.THEME)
            }
        })
        
    }
    
    var submitView: some View {
        ButtonWithLoader(
            action: {
                onSaveAndContinue()
            },
            title: "Save Details".localizedString(),
            width: screenWidth - (40 * 2),
            height: 41,
            isLoading: $viewModel.isLoading
        )
        .padding(.bottom, 30)
    }
    
    func setValues() {
        imageUrl = viewModel.profile.profileImage ?? Constants.EMPTY_STRING
        name = viewModel.profile.name
        email = viewModel.profile.email
        designation = viewModel.profile.designation ?? "NA"
        company = viewModel.profile.company ?? "NA"
    }
    
    func onSaveAndContinue() {
        viewModel.save(name: name, imageUrl: imageUrl, company: company, designation: designation, completed: { user in
            viewControllerHolder?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .UPDATE_PROFILE, object: nil)
            })
        })
    }
}

struct ProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileContentView(viewModel: .init())
    }
}

