//
//  NFCreateObservationContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import PhotosUI
import Alamofire
import SwiftUIX

struct NFCreateObservationContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = NFCreateObservationViewModel()
    @State private var isGroupView: Bool = false
    @State private var isGroupActive: Bool = false
    @State private var isGuest: Bool = UserManager.getCheckOutUser()?.isGuestUser ?? false
    @State private var groupData: GroupData?
    @State private var title = Constants.EMPTY_STRING
    @State private var reportedBy = UserManager.getLoginedUser()?.name ?? Constants.EMPTY_STRING
    @State private var location = Constants.EMPTY_STRING
    @State var userName = UserManager.getLoginedUser()?.name
    @State var imageCount: Int = 1
    @State private var description = Constants.EMPTY_STRING
    @State private var responsiblePerson = Constants.EMPTY_STRING
    @State private var responsiblePersonEmail = Constants.EMPTY_STRING
    @State private var isUserActive: Bool = false
    @State var imagesDatas: [ImageData] = []
    @State var minusButtonActive = false
    @State var userData: UserData?
    @State var userDatas: [UserData]?
    @State private var isUserActiveForNotification: Bool = false
    @State private var showBackButtonalert: Bool = false
    @State private var groupSpecifiedAlert: Bool = false
    @State private var successAlertforDraft: Bool = false
    @State private var successAlert: Bool = false
    @State var imageListId = UUID()
    @Binding var draftObservation: NFObservationDraftData
    @State var showImage: Bool = false
    @State private var imageData: String?
    @State private var projectId: String?
    var onObservationCreate: () -> Void
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    if !isGuest {
                        groupView
                            .padding(.top, 33.5)
                            .padding(.horizontal, 28)
                    }
                    
                    VStack(spacing: 26) {
                        titleView
                        
                        reportedByView
                        
                        locationView
                        
                        descriptionView
                        
                        responsiblePersonView
                        
                        LeftAlignedHStack(
                            Text("upload_images".localizedString())
                                .foregroundColor(Color.Blue.GREY)
                                .font(.regular(12))
                        )
                        
                        imageView
                        
                        if imagesDatas.endIndex < 6 {
                            Button {
                                imageCount = imageCount + 1
                            } label: {
                                HStack{
                                    Image(IC.ACTIONS.PLUS)
                                        .foregroundColor(Color.Green.DARK_GREEN)
                                    
                                    Text("add_image".localizedString())
                                        .foregroundColor(Color.Blue.THEME)
                                        .font(.regular(12))
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        ButtonWithLoader(
                            action: {
                                createObservation()
                            },
                            title: "publish".localizedString(),
                            width: screenWidth - (28 * 2),
                            height: 41,
                            isLoading: $viewModel.isLoading
                        )
                            .padding(.top, 9)
                        
                        Button {
                            saveAsDraft()
                        } label: {
                            Text("save_as_draft".localizedString())
                                .foregroundColor(Color.Orange.PINK)
                                .font(.regular(15))
                        }

                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 28)
                }
            }
            .navigationBarTitle("observation".localizedString(), displayMode: .inline)
            .onAppear(perform: {
                if viewModel.isEditing {
                    if imagesDatas.count <= 0 {
                        imagesDatas = [ImageData.dummy(imageCount: 1)]
                    }
                    setValues()
                } else {
                    imagesDatas = [ImageData.dummy(imageCount: 1)]
                }
            })
            .onChange(of: imageCount, perform: { (value) in
                let index = imagesDatas.endIndex
                imagesDatas.append(ImageData.dummy(imageCount: index + 1))
            })
            .onChange(of: groupData) { newValue in
                if newValue?.groupId == projectId { return }
                isUserActive = false
                userData = nil
                isUserActiveForNotification = false
                userDatas = []
            }
            .toolbar {
                BackButtonToolBarItem(action: {
                    showBackButtonalert.toggle()
                })
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
        .imageViewerOverlay(viewerShown: $showImage, images: [imageData ?? ""])
        .pickerViewerOverlay(viewerShown: $showBackButtonalert, title: "confirm_exit".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("confirm_exit_message".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        showBackButtonalert.toggle()
                    } label: {
                        Text("no".localizedString())
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("yes".localizedString())
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
        .pickerViewerOverlay(viewerShown: $groupSpecifiedAlert, title: "draft_saved".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("draft_saved_without_group".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        NotificationCenter.default.post(name: .UPDATE_DRAFT, object: nil)
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
        .pickerViewerOverlay(viewerShown: $successAlertforDraft, title: "draft_saved".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("draft_saved_message".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        NotificationCenter.default.post(name: .UPDATE_DRAFT, object: nil)
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
        .pickerViewerOverlay(viewerShown: $successAlert, title: "observation_created".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("observation_created_message".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                        onObservationCreate()
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
        .onChange(of: successAlert) { value in
            if !value {
                viewControllerHolder?.dismiss(animated: true, completion: nil)
                onObservationCreate()
            }
        }
        .onChange(of: successAlertforDraft) { value in
            if !value {
                viewControllerHolder?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var groupView: some View {
        VStack {
            HStack{
                Text("specify_a_project".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
                
                Spacer()
                
                Button {
                    withAnimation {
                        isGroupView.toggle()
                        if !isGroupView {
                            isGroupActive = false
                            groupData = nil
                        }
                    }
                    
                } label: {
                    Image(isGroupView ? IC.ACTIONS.TOGGLE_ON : IC.ACTIONS.TOGGLE_OFF)
                }
//                .onChange(of: isGroupView) { newValue in
//                    if !newValue {
//                        isGroupView = false
//                        self.groupData = nil
//                    }
//                }
            }
            .padding(.horizontal, 17)
            
            if isGroupView {
                VStack {
                    LeftAlignedHStack(
                        Text("select_a_project".localizedString())
                            .foregroundColor(Color.Grey.STEEL)
                            .font(.regular(12.5))
                    )
                    
                    if isGroupActive {
                        HStack(spacing: 10) {
                            WebUrlImage(url: groupData?.groupImage.url)
                                .frame(width: 44.5, height: 44.5)
                                .cornerRadius(22.25)
                            
                            VStack(spacing: 5) {
                                LeftAlignedHStack(
                                    Text(groupData?.groupName ?? "")
                                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                        .font(.medium(14))
                                )
                                
                                LeftAlignedHStack(
                                    Text(groupData?.groupCode ?? "")
                                        .foregroundColor(Color.Grey.SLATE)
                                        .font(.regular(13))
                                )
                            }
                            .padding(.leading, 19)
                            
                            Spacer()
                            
                            Image(IC.ACTIONS.CHECKBOX_ON)
                                .renderingMode(.original)
                                .frame(width: 18.0, height: 18.0)
                                .padding(.trailing, 5)
                        }
                        .padding(.top, 23)
                        .padding(.horizontal, 17)
                    }
                    
                    LeftAlignedHStack(
                        Button(action: {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFGroupListContentView(isFromViewGroup: false, isFromCreateObservation: true, isActive: $isGroupActive, groupData: $groupData)
                                    .localize()
                            }
                            
                        }, label: {
                            Text("select".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.medium(13))
                        })
                    )
                        .padding(.top, 15)
                }
                .padding(.top, 28.5)
                .padding(.horizontal, 17)
            }
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
    
    var titleView: some View {
        ThemeTextEditorView(
            text: $title,
            title: "title".localizedString(),
            disabled: false,
            isMandatoryField: true,
            limit: Constants.Number.Limit.Observation.TITLE,
        )
    }
    
    var reportedByView: some View {
        ThemeTextEditorView(
            text: $reportedBy,
            title: "reported_by".localizedString().uppercased(),
            placeholder: isGuest ? "reported_by".enterPlaceholder() : UserManager.getLoginedUser()?.name,
            disabled: true,
            isMandatoryField: true,
            limit: Constants.Number.Limit.Observation.REPORTED_BY,
            placeholderColor: isGuest ? Color.Grey.GUNMENTAL.opacity(0.25) : Color.Indigo.DARK,
            isPlaceHolderShown: true
        )
    }
    
    var locationView: some View {
        ThemeTextEditorView(
            text: $location,
            title: "location".localizedString(),
            disabled: false,
            isMandatoryField: false,
            limit: Constants.Number.Limit.Observation.LOCATION,
        )
    }
    
    var descriptionView: some View {
        ThemeTextEditorView(
            text: $description,
            title: "description".localizedString(),
            disabled: false,
            keyboardType: .asciiCapable, isMandatoryField: false,
            limit: Constants.Number.Limit.Observation.DESCRIPTION,
            placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: true)
    }
    
    var responsiblePersonView: some View {
        VStack(spacing: 26) {
            if !isGroupView || isGuest {
                ThemeTextEditorView(
                    text: $responsiblePerson,
                    title: "responsible_person".localizedString().uppercased(),
                    disabled: false,
                    isMandatoryField: false,
                    limit: Constants.Number.Limit.Observation.REPORTED_BY,
                )
                
                ThemeTextEditorView(
                    text: $responsiblePersonEmail,
                    title: "responsible_person_email".localizedString(),
                    disabled: false,
                    isMandatoryField: false,
                    isOptionalTextView: true
                )
            } else if isGroupView && isGroupActive {
                VStack {
                    LeftAlignedHStack(
                        Text("responsible_person".localizedString().uppercased())
                            .foregroundColor(Color.Blue.GREY)
                            .font(.regular(12))
                    )
                    
                    VStack {
                        if isUserActive {
                            if userData?.userId == -2 {
                                VStack(spacing: 8) {
                                    LeftAlignedHStack(
                                        Text("not_specified".localizedString())
                                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                            .font(.medium(15))
                                    )
                                    
                                    LeftAlignedHStack(
                                        Text("responsibility_for_all_project".localizedString())
                                            .foregroundColor(Color.Grey.SLATE)
                                            .font(.regular(12))
                                    )
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 17)
                            } else {
                                HStack(spacing: 10) {
                                    if userData?.userId != -3 {
                                        WebUrlImage(url: userData?.image.url)
                                            .frame(width: 44.5, height: 44.5)
                                            .cornerRadius(22.25)
                                    }
                                    
                                    VStack(spacing: 5) {
                                        LeftAlignedHStack(
                                            Text(userData?.name ?? "")
                                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                                .font(.medium(14))
                                        )
                                        
                                        LeftAlignedHStack(
                                            Text(userData?.email ?? "")
                                                .foregroundColor(Color.Grey.SLATE)
                                                .font(.regular(13))
                                        )
                                    }
                                    .padding(.leading, 19)
                                    
                                    Spacer()
                                    
                                    Image(IC.ACTIONS.CHECKBOX_ON)
                                        .renderingMode(.original)
                                        .frame(width: 18.0, height: 18.0)
                                        .padding(.trailing, 5)
                                }
                                .padding(.horizontal, 17)
                            }
                        }
                        
                        LeftAlignedHStack(
                            Button {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    UserListContentView(viewModel: .init(groupData: groupData ?? GroupData.dummy()), isFromSelectAUser: true, isUserActive: $isUserActive, isUserActiveForNotification: $isUserActiveForNotification, userData: $userData, userDatas: $userDatas)
                                        .localize()
                                }
                            } label: {
                                Text(isUserActive ? "change_user".localizedString() : "select_a_user".localizedString())
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.regular(13))
                            }
                                .padding(.horizontal, 17.5)
                        )
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                }
                
                VStack {
                    LeftAlignedHStack(
                        Text("send_notification_to".localizedString())
                            .foregroundColor(Color.Blue.GREY)
                            .font(.regular(12))
                    )
                    
                    VStack {
                        if isUserActiveForNotification {
                            ForEach(userDatas ?? [UserData.dummy()], id: \.userId) { user in
                                HStack(spacing: 10) {
                                    WebUrlImage(url: user.image.url)
                                        .frame(width: 44.5, height: 44.5)
                                        .cornerRadius(22.25)
                                    
                                    VStack(spacing: 5) {
                                        LeftAlignedHStack(
                                            Text(user.name)
                                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                                .font(.medium(14))
                                        )
                                        
                                        LeftAlignedHStack(
                                            Text(user.email)
                                                .foregroundColor(Color.Grey.SLATE)
                                                .font(.regular(13))
                                        )
                                    }
                                    .padding(.leading, 19)
                                    
                                    Spacer()
                                    
                                    Image(IC.ACTIONS.CHECKBOX_ON)
                                        .renderingMode(.original)
                                        .frame(width: 18.0, height: 18.0)
                                        .padding(.trailing, 5)
                                }
                                .padding(.horizontal, 17)
                            }
                        }
                        
                        LeftAlignedHStack(
                            Button {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    UserListContentView(viewModel: .init(groupData: groupData ?? GroupData.dummy()), isFromSelectAUser: false, isUserActive: $isUserActive, isUserActiveForNotification: $isUserActiveForNotification, userData: $userData, userDatas: $userDatas, forAvoidUser: true)
                                        .localize()
                                }
                            } label: {
                                Text("add_user".localizedString())
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.regular(13))
                            }
                                .padding(.horizontal, 17.5)
                        )
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                }
                .padding(.top, 20)
            }
        }
    }
    
    var imageView: some View {
        ForEach(imagesDatas.indices, id: \.self) { index in
            CreateImageView(
                imageUrlGenerated: { url in
                    imagesDatas[index].image = url
                }, descriptionChanged: { description in
                    imagesDatas[index].description = description
                }, minusButtonTapped: {
                    var images = imagesDatas
                    images.remove(at: index)
                    imagesDatas = images
                    imageListId = UUID()
                }, viewModel: CreateImageViewModel(item: imagesDatas[index], index: index),
                showImage: $showImage, imageUrlData: $imageData)
        }
        .id(imageListId)
    }
    
    func createObservation() {
        if !isGuest {
//            let groupSpecified = isGroupActive ? 1 : 0
            let groupSpecified = isGroupView ? 1 : 0
            let reportedBy = (isGuest ? reportedBy : UserManager().user?.name) ?? ""
            let notificationTo = userDatas?.map({$0.userId}) ?? []
            var customResponsiblePerson: CustomResponsiblePerson? = nil
            if userData?.userId == -3 {
                customResponsiblePerson = CustomResponsiblePerson(name: userData?.name ?? "", email: userData?.email)
            }
          
            
            viewModel.createObservation(observationId: draftObservation.id, observationTitle: title, reportedBy: reportedBy, location: location, description: description, groupSpecified: groupSpecified, groupId: groupData?.groupId.toInt ?? -1, notificationTo: notificationTo, responsiblePersonName: responsiblePerson, responsiblePerson: userData?.userId ?? -1, imageDescription: imagesDatas, customResponsiblePerson: customResponsiblePerson ?? CustomResponsiblePerson(name: ""), responsiblePersonEmail: responsiblePersonEmail) { completed in
                successAlert.toggle()
                NotificationCenter.default.post(name: .UPDATE_DRAFT, object: nil)
            }
        }  else {
            viewModel.guestCreateObservation(observationTitle: title, reportedBy: reportedBy, location: location, description: description, responsiblePerson: responsiblePerson, imageDescription: imagesDatas, responsiblePersonEmail: responsiblePersonEmail) { completed in
                successAlert.toggle()
                NotificationCenter.default.post(name: .UPDATE_DRAFT, object: nil)
            }
        }
    }
    
    func saveAsDraft() {
        let observationData: NFObservationDraftData
        let filteredImagesData = imagesDatas.filter { !$0.isDummy }

        if viewModel.isEditing {
            observationData = NFObservationDraftData(
                id: draftObservation.id,
                observationTitle: title,
                reportedBy: reportedBy,
                location: location,
                description: description,
                responsiblePersonName: responsiblePerson,
                responsiblePersonEmail: responsiblePersonEmail,
                projectResponsiblePerson: userData,
                sendNotification: userDatas,
                imageDescription: filteredImagesData,
                facilites: groupData,
                createdAt: Date().formattedDateString(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            )
        } else {
            observationData = NFObservationDraftData(
                id: -1,
                observationTitle: title,
                reportedBy: reportedBy,
                location: location,
                description: description,
                responsiblePersonName: responsiblePerson,
                responsiblePersonEmail: responsiblePersonEmail,
                projectResponsiblePerson: userData,
                sendNotification: userDatas,
                imageDescription: filteredImagesData,
                facilites: groupData,
                createdAt: Date().formattedDateString(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            )
        }
        viewModel.createDraftObservation(data: observationData) { completed in
            if isGroupActive {
                successAlertforDraft.toggle()
            } else {
                groupSpecifiedAlert.toggle()
            }
        }
    }

            
    
    func setValues() {
        isGroupView = draftObservation.facilites != nil
        isGroupActive = draftObservation.facilites != nil
        groupData = draftObservation.facilites
        projectId = draftObservation.facilites?.groupId
        title = draftObservation.observationTitle
        reportedBy = draftObservation.reportedBy
        location = draftObservation.location ?? ""
        description = draftObservation.description ?? ""
        responsiblePerson = draftObservation.responsiblePersonName ?? ""
        responsiblePersonEmail = draftObservation.responsiblePersonEmail ?? ""
        isUserActive = draftObservation.projectResponsiblePerson != nil
        isUserActiveForNotification = draftObservation.sendNotification != nil
        userData = draftObservation.projectResponsiblePerson
        userDatas = draftObservation.sendNotification
        imagesDatas = draftObservation.imageDescription ?? []
    }
    
    func printAllStateValues() {
        print("""
        🟢 Debug State Dump
        ────────────────────────
        isGroupView: \(isGroupView)
        isGroupActive: \(isGroupActive)
        isGuest: \(isGuest)
        groupData: \(String(describing: groupData))
        title: \(title)
        reportedBy: \(reportedBy)
        location: \(location)
        userName: \(String(describing: userName))
        imageCount: \(imageCount)
        description: \(description)
        responsiblePerson: \(responsiblePerson)
        responsiblePersonEmail: \(responsiblePersonEmail)
        isUserActive: \(isUserActive)
        imagesDatas: \(imagesDatas)
        minusButtonActive: \(minusButtonActive)
        userData: \(String(describing: userData))
        userDatas: \(String(describing: userDatas))
        isUserActiveForNotification: \(isUserActiveForNotification)
        showBackButtonalert: \(showBackButtonalert)
        groupSpecifiedAlert: \(groupSpecifiedAlert)
        successAlertforDraft: \(successAlertforDraft)
        successAlert: \(successAlert)
        imageListId: \(imageListId)
        draftObservation: \(draftObservation)
        showImage: \(showImage)
        imageData: \(String(describing: imageData))
        ────────────────────────
        """)
    }

}
