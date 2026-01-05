//
//  SettingsContentView.swift
// QualityExpertise
//
//  Created by developer on 18/02/22.
//

import SwiftUI
import PhotosUI
import SwiftfulLoadingIndicators

struct SettingsContentView: View {
    @Environment(\.layoutDirection) private var layoutDirection
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
    @State var showLanguagePicker: Bool = false
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
                            Text("account".localizedString())
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.semiBold(13.5))
                            
                            Spacer()
                        }

                        HStack {
                            Text("delete_your_account".localizedString())
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.regular())
                            
                            Spacer()
                            
                            Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                                .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                        }
                        .background(Color.white)
                        .onTapGesture {
                            viewControllerHolder?.present(style: .fullScreen) {
                                DeleteAccountContentView()
                                    .localize()
                            }
                        }

                    }
                    .padding(.bottom, 35)
                    .padding(.horizontal, 27.5)
                    
//                    changeLanguageView
//                        .padding(.horizontal, 27.5)
                }
                
                VStack {
                    if viewModel.isLoading {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .navigationBarTitle("settings".localizedString(), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isFromTabbar {
                        Button(action: {
                            if isFromDashboard {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    CustomTabBarContentView(selectedTab: .dashboard)
                                        .localize()
                                }
                            } else {
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            }
                        }) {
                            Image(IC.INDICATORS.BLACK_BACKWARD_ARROW)
                                .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
                        }
                    }
                }
            }
            .onAppear(perform: {
                if UserManager.getCheckOutUser()?.isGuestUser ?? false {
                    if UserManager.getCheckOutUser()?.guestDetails?.company != "" {
                        companyName = UserManager.getCheckOutUser()?.guestDetails?.company ?? ""
                    } else {
                        companyName = "na".localizedString()
                    }
                } else {
                    if UserManager.getUserDetails()?.companyName != "" {
                        companyName = UserManager.getUserDetails()?.companyName ?? ""
                    } else {
                        companyName = "na".localizedString()
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
        .pickerViewerOverlay(viewerShown: $showEditView, title: "company_details".localizedString()) {
            VStack(spacing: 20) {
                imageView
                
                ThemeTextEditorView(text: $companyName,
                                   title: "company_name".localizedString(),
                                    placeholder: "enter_your_company_name".localizedString(), disabled: false,
                                    keyboardType: .default,
                                   limit: Constants.Number.Limit.COMPANY,
                                   isDividerShown: false)
                
                Button {
                    updateCompanyDetails()
                } label: {
                    Text("save_details".localizedString())
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
        .pickerViewerOverlay(viewerShown: $isEmailNotificationToggle, title: "email_notification".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text(emailNotificationEnabled ? "disable_email_notification".localizedString() : "enable_email_notification".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        isEmailNotificationToggle.toggle()
                    } label: {
                        Text("cancel".localizedString())
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
                        Text(emailNotificationEnabled ? "disable".localizedString() : "enable".localizedString())
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
        .pickerViewerOverlay(viewerShown: $isAppNotificationToggle, title: "app_notifications".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text(appNotificationEnabled ? "disable_email_notification".localizedString() : "enable_email_notification")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        isAppNotificationToggle.toggle()
                    } label: {
                        Text("cancel".localizedString())
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
                        Text(appNotificationEnabled ? "disable".localizedString() : "enable".localizedString())
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
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
    }
    
    var companyDetailsView: some View {
        VStack {
            LeftAlignedHStack(
                Text("company_details_title".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
            )
            
            HStack(spacing: 13) {
                ZStack {
                    WebUrlImage(url: UserManager.getCheckOutUser()?.isGuestUser ?? false ? UserManager.getCheckOutUser()?.guestDetails?.companyLogo?.url : UserManager.getUserDetails()?.companyLogo?.url, placeholderImage: Image(IC.PLACEHOLDER.LOGO))
                        .frame(width: 102, height: 102)
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
                                Text("na".localizedString())
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
                                Text("na".localizedString())
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
                            Text("edit".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        )
                    }
                    .clipShape(Rectangle())
                    
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
                .frame(width: 102, height: 102)
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
    
    var setLocationPdf: some View {
        VStack(spacing: 0) {
            LeftAlignedHStack(
                Text("download_location_of_pdf".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
            )
            
            HStack {
                Text("view_location".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.medium(13))
                
                Spacer()
                
                Button {
                    
                    let path = getDocumentsDirectory().absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                    let url = URL(string: path)!
                    
                    UIApplication.shared.open(url)
                } label: {
                    Text("view".localizedString())
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
                
                Text("notifications".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
                
                Spacer()
            }
            
            SwitchView(title: "email_notifications".localizedString(),
                       isOn: $emailNotificationEnabled) {
                isEmailNotificationToggle.toggle()
            }
            
            SwitchView(title: "app_notifications".localizedString(),
                       isOn: $appNotificationEnabled) {
                isAppNotificationToggle.toggle()
            }
        }
    }
    
    var changeLanguageView: some View {
        VStack {
            HStack(spacing: 12) {
                Image("ic.language.app.icon")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("app_language".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
                
                Spacer()
            }
            .padding(.bottom, 30)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("change_app_language".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular())
                    Text(LocalizationService.shared.language.description)
                        .foregroundColor(Color.Grey.SLATE)
                        .font(.regular(12))
                }
                
                Spacer()
                
                Image(IC.INDICATORS.GOTO_RIGHT_ARROW_GREY)
                    .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
            }
            .background(Color.white)
            .onTapGesture {
                viewControllerHolder?.present(style: .fullScreen) {
                    LanguagePickerView(viewModel: viewModel) { selectedLanguage in
                        if selectedLanguage != LocalizationService.shared.language {
                            LocalizationService.shared.language = selectedLanguage
                            relaunchApp()
                        }
                    }
                    .localize()
                }
            }
        }
        .padding(.bottom, 50)
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
            UserManager.shared.userDetails?.companyName = companyName
            UserManager.shared.userDetails?.companyLogo = imageUrl
            showEditView.toggle()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func relaunchApp() {
        viewModel.isLoading = true
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.dismiss(animated: true) {
                    NotificationCenter.default.post(name: .RELAUNCH_APP, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .RELAUNCH_APP, object: nil)
            }
        }
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
