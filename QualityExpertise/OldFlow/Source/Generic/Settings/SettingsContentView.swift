//
//  SettingsContentView.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import SwiftUI
import PhotosUI
import SwiftfulLoadingIndicators

struct SettingsContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = SettingsViewModel()
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var imageUrl = Constants.EMPTY_STRING
    @State private var isImagePickFromCamera = false
    @State private var isImagePickFromGallery = false
    @State private var imageUploadStatus = UploadStatus.pending
    @State private var showEditView = false
    @State private var companyName = Constants.EMPTY_STRING
    @State var emailNotificationEnabled = false
    @State var appNotificationEnabled = false
    @State var isEmailNotificationToggle = false
    @State var isAppNotificationToggle = false
    @State var isFromDashboard = true
    @State var tempImgaeUrl = UserManager.getUserDetails()?.companyLogo
    var isFromTabbar: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView{
                    VStack(spacing: 30) {
                        companyDetailsView
                            .padding(.top, 20)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                        
                        setLocationPdf
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                        
                        if !viewModel.user.isGuestUser {
                            notificationsView
                        }
                        
                        HStack(spacing: 12) {
                            Image(IC.LOGO.USER_CLEAR)
                            Text("Account")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.semiBold(13.5))
                            
                            Spacer()
                        }

                        HStack {
                            Text("Delete your account")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.regular())
                            
                            Spacer()
                            
                            Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                        }
                        .background(Color.white)
                        .onTapGesture {
                            viewControllerHolder?.present(style: .fullScreen) {
                                DeleteAccountContentView()
                            }
                        }

                    }
                    .padding(.bottom, 35)
                    .padding(.horizontal, 27.5)
                }
                
                VStack {
                    if viewModel.isLoading {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isFromTabbar {
                        Button(action: {
                            if isFromDashboard {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    TabBarContentView(selectedTab: 0)
                                }
                            } else {
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            }
                        }) {
                            Image(IC.INDICATORS.BLACK_BACKWARD_ARROW)
                        }
                    }
                }
            }
            .onAppear(perform: {
                if UserManager.getCheckOutUser()?.isGuestUser ?? false {
                    if UserManager.getCheckOutUser()?.guestDetails?.company != "" {
                        companyName = UserManager.getCheckOutUser()?.guestDetails?.company ?? ""
                    } else {
                        companyName = "NA"
                    }
                } else {
                    if UserManager.getUserDetails()?.companyName != "" {
                        companyName = UserManager.getUserDetails()?.companyName ?? ""
                    } else {
                        companyName = "NA"
                    }
                }
                
                imageUrl = viewModel.user.isGuestUser ? UserManager.getCheckOutUser()?.guestDetails?.companyLogo ?? "" : UserManager.getUserDetails()?.companyLogo ?? ""
                emailNotificationEnabled = UserManager().settings?.emailNotification ?? false
                appNotificationEnabled = UserManager().settings?.appNotification ?? false
            })
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: $showEditView, title: "Company Details") {
            VStack(spacing: 20) {
                imageView
                
                ThemeTextFieldView(text: $companyName,
                                   title: "COMPANY NAME",
                                   disabled: false,
                                   keyboardType: .asciiCapable,
                                   placeholder: "Enter your Company Name",
                                   limit: Constants.Number.Limit.COMPANY,
                                   autocapitalizationType: .words,
                                   isDividerShown: false)
                
                Button {
                    updateCompanyDetails()
                } label: {
                    Text("Save Details")
                        .foregroundColor(Color.white)
                        .font(.semiBold(12))
                        .frame(maxWidth: .infinity, minHeight: 35)
                }
                .background(Color.Blue.THEME)
                .cornerRadius(17.5)
                
                //                Button {
                //                    imageUrl = ""
                //                    updateCompanyDetails()
                //                } label: {
                //                    Text("Reset To Default")
                //                        .foregroundColor(Color.Indigo.DARK)
                //                        .font(.medium(12))
                //                }
                .padding(.bottom, 10)
                
            }
        }
        .pickerViewerOverlay(viewerShown: $isEmailNotificationToggle, title: "Email Notification".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text(emailNotificationEnabled ? "Disable Email Notification" : "Enable Email Notification")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        isEmailNotificationToggle.toggle()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        settingsAction(type: .emailNotification)
                    } label: {
                        Text(emailNotificationEnabled ? "Disable" : "Enable")
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
        .pickerViewerOverlay(viewerShown: $isAppNotificationToggle, title: "App Notification".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text(appNotificationEnabled ? "Disable App Notification" : "Enable App Notification")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        isAppNotificationToggle.toggle()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        settingsAction(type: .appNotification)
                    } label: {
                        Text(appNotificationEnabled ? "Disable" : "Enable")
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
    
    var companyDetailsView: some View {
        VStack {
            LeftAlignedHStack(
                Text("Company Details")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
            )
            
            HStack(spacing: 13) {
                ZStack {
                    WebUrlImage(url: UserManager.getCheckOutUser()?.isGuestUser ?? false ? UserManager.getCheckOutUser()?.guestDetails?.companyLogo?.url : UserManager.getUserDetails()?.companyLogo?.url, placeholderImage: Image(IC.PLACEHOLDER.LOGO))
                        .cornerRadius(102/2)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Group {
                                Button(action: {
                                    if let companyLogo = viewModel.user.isGuestUser ?  UserManager.getCheckOutUser()?.guestDetails?.companyLogo : UserManager.getUserDetails()?.companyLogo {
                                        imageUrl = companyLogo
                                    }
                                    isImagePickerDisplay.toggle()
                                    showEditView.toggle()
                                }, label: {
                                    Image(IC.ACTIONS.ADD_PROFILE_IMAGE)
                                })
                            }
                            .frame(width: 28.5, height: 28.5, alignment: .center)
                        }
                    }
                }
                .frame(width: 102, height: 102, alignment: .center)
                
                
                VStack(spacing: 15) {
                    if UserManager.getCheckOutUser()?.isGuestUser ?? false {
                        if UserManager.getCheckOutUser()?.guestDetails?.company != "" {
                            LeftAlignedHStack(
                                Text(UserManager.getCheckOutUser()?.guestDetails?.company ?? "")
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.semiBold(17.5))
                            )
                        } else {
                            LeftAlignedHStack(
                                Text("NA")
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.semiBold(17.5))
                            )
                        }
                    } else {
                        if UserManager.getUserDetails()?.companyName != "" {
                            LeftAlignedHStack(
                                Text(UserManager.getUserDetails()?.companyName ?? "")
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.semiBold(17.5)))
                        } else {
                            LeftAlignedHStack(
                                Text("NA")
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.semiBold(17.5))
                            )
                        }
                    }
                    
                    
                    Button {
                        if let companyLogo = viewModel.user.isGuestUser ?  UserManager.getCheckOutUser()?.guestDetails?.companyLogo : UserManager.getUserDetails()?.companyLogo {
                            imageUrl = companyLogo
                        }
                        showEditView.toggle()
                    } label: {
                        LeftAlignedHStack(
                            Text("Edit")
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        )
                    }
                    
                }
                
                Spacer()
            }
            
        }
    }
    
    var imageView: some View {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        return ZStack {
            
            WebUrlImage(url: imageUrl.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                .cornerRadius(102/2)

            if imageUrl != "" && imageUploadStatus != .inProgress {
                VStack {
                    Spacer()
                    Group {
                        Button {
                            imageUrl = ""
                        } label: {
                            Image(IC.ACTIONS.CLOSE_WHITE)
                                .overlay(
                                    Circle()
                                        .stroke(Color.Indigo.DUSK_FOUR_15, lineWidth: 1.0)
                                )
                        }
                    }
                    .padding(.top, -85)
                    .padding(.trailing, -95)
                    .frame(width: 45, height: 15, alignment: .topTrailing)
                }
            }
            
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
                            })
                        }
                        .frame(width: 28.5, height: 28.5, alignment: .center)
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
    
    var setLocationPdf: some View {
        VStack(spacing: 0) {
            LeftAlignedHStack(
                Text("Download Location Of PDF")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
            )
            
            HStack {
                Text("View Location")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.medium(13))
                
                Spacer()
                
                Button {
                    
                    let path = getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                    let url = URL(string: path)!
                    
                    UIApplication.shared.open(url)
                } label: {
                    Text("View")
                        .foregroundColor(Color.white)
                        .font(.regular(12))
                        .frame(width: 60, height: 25)
                }
                .background(Color.Blue.THEME)
                .cornerRadius(12.5)
                
                
            }
            .padding(.top, 30)
            
            LeftAlignedHStack(
                Text(getDocumentsDirectory().lastPathComponent)
                    .foregroundColor(Color.Grey.SLATE)
                    .font(.medium(13))
                    .lineLimit(1)
                    .truncationMode(.head)
            )
                .padding(.top, 5)
        }
    }
    
    var notificationsView: some View {
        VStack(spacing: 23) {
            HStack(spacing: 12) {
                Image(IC.LOGO.NOTIFCATIONS_CLEAR)
                
                Text("Notifications")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
                
                Spacer()
            }
            
            SwitchView(title: "Email Notifications".localizedString(),
                       isOn: $emailNotificationEnabled) {
                isEmailNotificationToggle.toggle()
            }
            
            SwitchView(title: "App Notifications".localizedString(),
                       isOn: $appNotificationEnabled) {
                isAppNotificationToggle.toggle()
            }
        }
    }
    
    func settingsAction(type: SettingsType) {
        viewModel.userSettings(type: type) {emailNotificationEnabled, appNotificationEnabled in
            self.emailNotificationEnabled = emailNotificationEnabled
            self.appNotificationEnabled = appNotificationEnabled
            if type == .emailNotification {
                isEmailNotificationToggle.toggle()
            } else {
                isAppNotificationToggle.toggle()
            }
        }
    }
    
    func updateCompanyDetails() {
        viewModel.updateCompanyDetails(companyName: companyName, companyLogo: imageUrl) { completed in
            UserManager.instance.userDetails?.companyName = companyName
            UserManager.instance.userDetails?.companyLogo = imageUrl
            showEditView.toggle()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension SettingsContentView {
    struct SwitchView: View {
        let title: String
        @Binding var isOn: Bool
        var action: () -> ()
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.regular())
                    .foregroundColor(Color.Indigo.DARK)
                
                Spacer()
                
                Button {
                    action()
                } label: {
                    Toggle("", isOn: $isOn)
                        .toggleStyle(SwitchToggleStyle(tint: Color.Blue.THEME))
                        .labelsHidden()
                        .disabled(true)
                }
            }
        }
    }
}
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView()
    }
}
