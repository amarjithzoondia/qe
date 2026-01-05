//
//  CreateObservationContentView.swift
// ALNASR
//
//  Created by developer on 31/01/22.
//

import SwiftUI
import PhotosUI
import Alamofire
import SwiftUIX

struct CreateObservationContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = CreateObservationViewModel()
    @State private var isGroupView: Bool = false
    @State private var isGroupActive: Bool = false
    @State private var isGuest: Bool = UserManager.getCheckOutUser()?.isGuestUser ?? false
    @State private var groupData: GroupData?
    @State private var title = Constants.EMPTY_STRING
    @State private var reportedBy = Constants.EMPTY_STRING
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
    @Binding var draftObservation: ObservationDraftData
    @State var showImage: Bool = false
    @State private var imageData: String?
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
                            Text("UPLOAD IMAGES")
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
                                    
                                    Text("Add Image")
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
                            title: "Publish".localizedString(),
                            width: screenWidth - (28 * 2),
                            height: 41,
                            isLoading: $viewModel.isLoading
                        )
                            .padding(.top, 9)
                        
                        Button {
                            saveAsDraft()
                        } label: {
                            Text("Save as Draft")
                                .foregroundColor(Color.Orange.PINK)
                                .font(.regular(15))
                        }

                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 28)
                }
            }
            .navigationBarTitle("Observation", displayMode: .inline)
            .onAppear(perform: {
                print(index)
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
        .pickerViewerOverlay(viewerShown: $showBackButtonalert, title: "Confirm Exit!".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Are you sure you want to leave this page, All unsaved changes will be lost.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        showBackButtonalert.toggle()
                    } label: {
                        Text("No")
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
                        Text("Yes")
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
        .pickerViewerOverlay(viewerShown: $groupSpecifiedAlert, title: "Draft Saved".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Observation successfully saved as draft without group Specifications.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            TabBarContentView(selectedTab: 0)
                        }
                    } label: {
                        Text("Okay")
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
        .pickerViewerOverlay(viewerShown: $successAlertforDraft, title: "Draft Saved".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Observation successfully saved as draft.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        NotificationCenter.default.post(name: .UPDATE_DRAFT, object: nil)
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("Okay")
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
        .pickerViewerOverlay(viewerShown: $successAlert, title: "Observation created".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Observation created successfully.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("Okay")
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
            }
        }
    }
    
    var groupView: some View {
        VStack {
            HStack{
                Text("Specify a Group")
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(13.5))
                
                Spacer()
                
                Button {
                    isGroupView.toggle()
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
                        Text("SELECT GROUP")
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
                                GroupListContentView(isFromCreateObservation: true, isActive: $isGroupActive, groupData: $groupData)
                            }
                            
                        }, label: {
                            Text("Select")
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
        ThemeTextFieldView(
            text: $title,
            title: "TITLE".localizedString(),
            disabled: false,
            isMandatoryField: false,
            limit: Constants.Number.Limit.Observation.TITLE,
            autocapitalizationType: .words
        )
    }
    
    var reportedByView: some View {
        ThemeTextFieldView(
            text: $reportedBy,
            title: "REPORTED BY".localizedString(),
            disabled: isGuest ? false : true,
            placeholder: isGuest ? "REPORTED BY".enterPlaceholder() : UserManager.getLoginedUser()?.name,
            isMandatoryField: false,
            limit: Constants.Number.Limit.Observation.REPORTED_BY,
            autocapitalizationType: .words,
            placeholderColor: isGuest ? Color.Grey.GUNMENTAL.opacity(0.25) : Color.Indigo.DARK
        )
    }
    
    var locationView: some View {
        ThemeTextFieldView(
            text: $location,
            title: "LOCATION".localizedString(),
            disabled: false,
            isMandatoryField: false,
            limit: Constants.Number.Limit.Observation.LOCATION,
            autocapitalizationType: .words
        )
    }
    
    var descriptionView: some View {
        ThemeTextEditorView(
            text: $description,
            title: "DESCRIPTION".localizedString(),
            disabled: false,
            keyboardType: .asciiCapable, isMandatoryField: false,
            limit: Constants.Number.Limit.Observation.DESCRIPTION,
            placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: true)
    }
    
    var responsiblePersonView: some View {
        VStack(spacing: 26) {
            if !isGroupView || isGuest {
                ThemeTextFieldView(
                    text: $responsiblePerson,
                    title: "RESPONSIBLE PERSON".localizedString(),
                    disabled: false,
                    isMandatoryField: false,
                    limit: Constants.Number.Limit.Observation.REPORTED_BY,
                    autocapitalizationType: .words
                )
                
                ThemeTextFieldView(
                    text: $responsiblePersonEmail,
                    title: "RESPONSIBLE PERSON EMAIL".localizedString(),
                    disabled: false,
                    isMandatoryField: false,
                    autocapitalizationType: .none,
                    isOptionalTextView: true
                )
            } else if isGroupView && isGroupActive {
                VStack {
                    LeftAlignedHStack(
                        Text("RESPONSIBLE PERSON")
                            .foregroundColor(Color.Blue.GREY)
                            .font(.regular(12))
                    )
                    
                    VStack {
                        if isUserActive {
                            if userData?.userId == -2 {
                                VStack(spacing: 8) {
                                    LeftAlignedHStack(
                                        Text("Not Specified")
                                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                            .font(.medium(15))
                                    )
                                    
                                    LeftAlignedHStack(
                                        Text("Responsibility for all group members")
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
                                }
                            } label: {
                                Text(isUserActive ? "Change user" : "Select a user")
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
                        Text("SEND NOTIFICATION TO")
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
                                }
                            } label: {
                                Text("+ Add User")
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
          
            
            viewModel.createObservation(observationTitle: title, reportedBy: reportedBy, location: location, description: description, groupSpecified: groupSpecified, groupId: groupData?.groupId.toInt ?? -1, notificationTo: notificationTo, responsiblePersonName: responsiblePerson, responsiblePerson: userData?.userId ?? -1, imageDescription: imagesDatas, customResponsiblePerson: customResponsiblePerson ?? CustomResponsiblePerson(name: ""), responsiblePersonEmail: responsiblePersonEmail) { completed in
                successAlert.toggle()
            }
        }  else {
            viewModel.guestCreateObservation(observationTitle: title, reportedBy: reportedBy, location: location, description: description, responsiblePerson: responsiblePerson, imageDescription: imagesDatas, responsiblePersonEmail: responsiblePersonEmail) { completed in
                successAlert.toggle()
            }
        }
        
        if viewModel.isEditing {
            var draftObservations = UserManager.getObservationDraftList()
            if let index = draftObservations.firstIndex(where: {$0 == draftObservation}) {
                draftObservations.remove(at: index)
                UserManager.saveObservationDraftData(datas: draftObservations)
                NotificationCenter.default.post(name: .UPDATE_DRAFT, object: nil)
            }
        }
    }
    
    func saveAsDraft() {
        var dbId = 0
        var data = [ObservationDraftData]()
        let observationList = UserManager.getObservationDraftList()
        data.append(contentsOf: observationList)
        let draftObservation = draftObservation
        
        if !(viewModel.isEditing) {
            if let lastobservationData = data.last {
                dbId = (lastobservationData.id) + 1
            } else {
                dbId = dbId + 1
            }
            
        }
        do {
            let observationTitle = try title.validatedText(validationType: .requiredField(field: "Observation Title".localizedString()))
            
            let observationData: ObservationDraftData
            
            if viewModel.isEditing {
                let index = data.firstIndex(where: { $0 == draftObservation})
                data.remove(at: index ?? -1)
                observationData = ObservationDraftData(id: draftObservation.id, observationTitle: observationTitle, reportedBy: reportedBy, location: location, description: description, responsiblePersonName: responsiblePerson, imageDescription: imagesDatas, createdTime: draftObservation.createdTime, updatedTime: Date().formattedDateString(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"))
                data.insert(observationData, at: index!)
            } else {
                observationData = ObservationDraftData(id: dbId, observationTitle: observationTitle, reportedBy: reportedBy, location: location, description: description, responsiblePersonName: responsiblePerson, imageDescription: imagesDatas, createdTime: Date().formattedDateString(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), updatedTime: "")
                data.append(observationData)
            }
            
            UserManager.saveObservationDraftData(datas: data)
            if isGroupActive {
                groupSpecifiedAlert.toggle()
            } else {
                successAlertforDraft.toggle()
            }
        } catch {
            viewModel.toast = (error as! SystemError).toast
        }
            
    }
    
    func setValues() {
        title = draftObservation.observationTitle
        reportedBy = draftObservation.reportedBy ?? ""
        location = draftObservation.location ?? ""
        description = draftObservation.description ?? ""
        responsiblePerson = draftObservation.responsiblePersonName
        imagesDatas = draftObservation.imageDescription
    }
}
