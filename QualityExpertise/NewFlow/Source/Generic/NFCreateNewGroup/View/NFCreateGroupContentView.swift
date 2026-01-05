//
//  NFCreateGroupContentView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//


import SwiftUI
import PhotosUI
import SwiftfulLoadingIndicators

struct NFCreateGroupContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: NFCreateGroupViewModel
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var imageUrl = Constants.EMPTY_STRING
    @State private var isImagePickFromCamera = false
    @State private var isImagePickFromGallery = false
    @State private var imageUploadStatus = UploadStatus.pending
    @State private var title = Constants.EMPTY_STRING
    @State private var description = Constants.EMPTY_STRING
    let closePublisher = NotificationCenter.default.publisher(for: .CLOSE_BOOKING_FLOW)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView {
                        
                        VStack(spacing: 26) {
                            imageView
                                .padding(.top, 51.5)
                            
                            titleView
                                .padding(.horizontal, 20)
                            
                            descriptionView
                                .padding(.horizontal, 20)
                            
                            if viewModel.isEditing {
                                Button {
                                    onCreateAndContinue()
                                } label: {
                                    Text("save_details".localizedString())
                                        .foregroundColor(Color.white)
                                        .font(.medium(16))
                                        .frame(maxWidth: .infinity, minHeight: 45)
                                }
                                .background(Color.Blue.THEME)
                                .cornerRadius(27.5)
                            }
                        }
                    }
                    Spacer()
                    
                    if !viewModel.isEditing {
                        HStack {
                            Spacer()
                            
                            Button {
                                onCreateAndContinue()
                            } label: {
                                HStack {
                                    Text("next".localizedString())
                                        .foregroundColor(Color.white)
                                        .font(.medium(16))
                                    
                                    Image(IC.INDICATORS.WHITE_FORWARD_ARROW)
                                }
                                .frame(width: 106, height: 45)
                                .background(Color.Blue.THEME)
                                .cornerRadius(27.5)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 27.5)
                
                
                if viewModel.isLoading {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    Color.white.opacity(0.75)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitle(viewModel.isEditing ? "edit_project".localizedString() : "new_project".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .onReceive(closePublisher) { (output) in
                viewControllerHolder?.dismiss(animated: true)
            }
            .onAppear {
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
            // Profile Image
            WebUrlImage(url: imageUrl.url, placeholderImage: Image(IC.PLACEHOLDER.GROUP))
                .resizable()
                .scaledToFill()
                .frame(width: 102, height: 102)
                .clipShape(Circle())
            VStack {
                if imageUploadStatus == .inProgress {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                } else {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isImagePickerDisplay.toggle()
                        }, label: {
                            Image(IC.ACTIONS.ADD_PROFILE_IMAGE)
                                .resizable()
                                .frame(width: 28.5, height: 28.5)
                                .padding(4)
                        })
                    }
                }
            }
            .frame(width: 102, height: 102)
        }
        .frame(width: 102, height: 102)
        .actionSheet(isPresented: $isImagePickerDisplay) {
            ActionSheet(
                title: Text("choose_image".localizedString()),
                message: Text("select_a_method".localizedString()),
                buttons: [
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
                ]
            )
        }
        .onChange(of: selectedImage) { value in
            viewModel.upload(image: value) { isLoading in
                imageUploadStatus = .inProgress
            } completed: { url in
                imageUploadStatus = .completed(url: url)
                imageUrl = url
            } failure: {
                imageUploadStatus = .failure
            }
        }
    }
    
    var titleView: some View {
        ThemeTextEditorView(
            text: $title,
            title: "project_title".localizedString(),
            disabled: false,
            isMandatoryField: false,
            limit: Constants.Number.Limit.GROUP_NAME,
            isPlaceHolderShown: true
        )
    }
    
    var descriptionView: some View {
        ThemeTextEditorView(
            text: $description,
            title: "description".localizedString(),
            disabled: false,
            keyboardType: .asciiCapable,
            isMandatoryField: false,
            limit: Constants.Number.Limit.DESCRIPTION,
            placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: true
        )
    }
    
    func onCreateAndContinue() {
        closeKeyboard()
        
        viewModel.createGroup(title: title, description: description, image: imageUrl) { completed in
            if viewModel.isEditing {
                NotificationCenter.default.post(name: .UPDATE_GROUP,
                                                object: nil)
                viewControllerHolder?.dismiss(animated: true, completion: nil)
            } else {
                viewControllerHolder?.present(style: .overCurrentContext) {
                    NFGroupCreationSuccessContentView(viewModel: .init(groupdetails: viewModel.groupDetails!))
                        .localize()
                }
            }
        }
    }
    
    func setValues() {
        imageUrl = viewModel.image
        print(viewModel.groupName)
        title = viewModel.groupName
        description = viewModel.description
    }
}

struct NFCreateGroupContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFCreateGroupContentView(viewModel: .init(isEditing: false, groupName: "", description: "", image: "", groupCode: ""))
    }
}
