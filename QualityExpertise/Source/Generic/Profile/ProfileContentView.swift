//
//  ProfileContentView.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import SwiftUI
import PhotosUI
import SwiftfulLoadingIndicators

struct ProfileContentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.layoutDirection) private var layoutDirection
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
            .navigationBarTitle(viewModel.isEditing ? "edit_profile".localizedString() : "my_profile".localizedString(), displayMode: .inline)
            .onAppear {
                setValues()
            }
            .navigationBarItems(
                trailing: viewModel.isEditing ? nil : Button(action: {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        ProfileContentView(viewModel: .init(isEditing: true))
                            .localize()
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
                .frame(width: 102, height: 102)
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
                                })
                            }
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
            text: $name,
            title: "name".localizedString(),
            disabled: !viewModel.isEditing,
            isMandatoryField: false
        )
    }
    
    var emailView: some View {
        ThemeTextEditorView(
            text: $email,
            title: "email".localizedString(),
            placeholder: UserManager.getLoginedUser()?.email, disabled: true,
            isMandatoryField: false,
            isPlaceHolderShown: true
        )
    }
    
    var designationView: some View {
        ThemeTextEditorView(
            text: $designation,
            title: "designation".localizedString(),
            disabled: !viewModel.isEditing,
            keyboardType: .default,
            isMandatoryField: false,
        )
    }
    
    var companyView: some View {
        ThemeTextEditorView(
            text: $company,
            title: "company_name".localizedString(),
            disabled: !viewModel.isEditing,
            keyboardType: .default,
            isMandatoryField: false,
        )
    }
    
    var changePasswordView: some View {
        Button(action: {
            viewControllerHolder?.present(style: .overCurrentContext) {
                ChangePasswordContentView()
                    .localize()
            }
        }, label: {
            HStack(spacing: 0) {
                Text("change_your_password".localizedString())
                    .foregroundColor(Color.Blue.THEME)
                    .font(.medium(13))
                
                Spacer()
                
                Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                    .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                    .foregroundColor(Color.Blue.THEME)
            }
        })
        
    }
    
    var submitView: some View {
        ButtonWithLoader(
            action: {
                onSaveAndContinue()
            },
            title: "save_details".localizedString(),
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

