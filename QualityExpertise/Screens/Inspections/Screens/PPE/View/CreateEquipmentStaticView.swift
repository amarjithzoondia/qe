//
//  EquipmentStaticView.swift
//  ALNASR
//
//  Created by Amarjith B on 02/06/25.
//

import SwiftUI

struct CreateEquipmentStaticView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode
    @State private var isProjectOption: Bool = false
    @State private var isGroupView: Bool = false
    @State private var isGroupActive: Bool = false
    @State private var groupData: GroupData? = nil
    
    @State private var identificationNumber: String = ""
    @State private var inspectedBy: String = (UserManager.getLoginedUser()?.name ?? "")
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var selectedEquipmentSource: EquipmentSource?
    @State private var rentalOrSubContractor: String = ""
    @State private var notes: String = ""
    
    @State var imagesDatas: [ImageData] = []
    @State var imageListId = UUID()
    @State var showImage: Bool = false
    @State private var imageData: String?
    @State var imageCount: Int = 1
    
    @State var showBackButtonalert: Bool = false
    @State var showSuccessAlert: Bool = false
    @State var showShareDocumentAlert: Bool = false
    
    @State var isRentalOrSubContractor: Bool = false
    
    @StateObject var viewModel: CreateEquipmentStaticViewModel
    
    @Binding var isListChanged: Bool
    
    var inspectionType: AuditsInspectionsList
    var isViewOnly: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    contentView
                    
                }
                .onAppear {
                    if isViewOnly {
                        viewModel.fetchInspectionDetails()
                    } else {
                        imagesDatas = [ImageData.dummy(imageCount: 1)]
                        viewModel.fetchStaticEquipmentData()
                    }
                }
                .onReceive(viewModel.$inspectionView.compactMap { $0 }) { inspections in
                    withAnimation {
                        self.isProjectOption = (inspections.facilities != nil)
                        self.isGroupView = (inspections.facilities != nil)
                        self.isGroupActive = (inspections.facilities != nil)
                        self.groupData = inspections.facilities
                        self.identificationNumber = inspections.modelNumber
                        self.inspectedBy = inspections.inspectedBy
                        self.location = inspections.location
                        self.description = inspections.description
                        self.selectedEquipmentSource = inspections.equipmentSource
                        self.rentalOrSubContractor = inspections.subContractor ?? ""
                        self.notes = inspections.notes
                        self.imagesDatas = inspections.images ?? []
                        self.imageCount = inspections.images?.count ?? 0
                    }
                }
                .onChange(of: imageCount, perform: { (value) in
                    let index = imagesDatas.endIndex
                    imagesDatas.append(ImageData.dummy(imageCount: index + 1))
                })
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    if isViewOnly {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } else {
                        showBackButtonalert.toggle()
                    }
                })
                
                
                    ToolbarItem(placement: .topBarTrailing) {
                        if isViewOnly {
                        HStack(spacing: 5){
                            Button {
                                generatePdf()
                            } label: {
                                Text("Generate PDF")
                                    .foregroundColor(Color.white)
                                    .font(.medium(12))
                                    .frame(width: 125, height: 33.5)
                                    .background(Color.Blue.THEME)
                                    .cornerRadius(16.75)
                            }
                            
                            Button {
                                showShareDocumentAlert.toggle()
                            } label: {
                                Image(IC.ACTIONS.SHARE)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
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
        .onChange(of: showSuccessAlert) { newValue in
            /// Dismissing the current view when close button is tapped in success alert picker
            if !newValue {
                viewControllerHolder?.dismiss(animated: true, completion: nil)
            }
            
        }
        .pickerViewerOverlay(viewerShown: $showSuccessAlert, title: "Inspection created".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Inspection created successfully.")
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
        .overlay(ShareObservationAlertView(viewerShown: $showShareDocumentAlert) { isPDFSelected in
            
            if !isPDFSelected {
                let message = viewModel.getShareMessage()
                let urlWhats = "whatsapp://send?text=\(message)"
                if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                    if let whatsappURL = URL(string: urlString) {
                        if UIApplication.shared.canOpenURL(whatsappURL) {
                            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                        }
                    }
                }
            } else {
                viewModel.generatePdf { completed in
                    viewModel.sharePdf(urlString: viewModel.pdfUrl, completion: { pdfData in
                        showActivityViewController(activities: [pdfData as Any])
                    })
                }
            }
        })
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
        
        
    }
    
    
    private var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            headingContent
                .padding(.horizontal, 25)
                .padding(.top, 10)
            
            specifyProjectToggleBar
                .padding(.horizontal, 25)
                .disabled(isViewOnly)
            
            formView
                .padding(.horizontal, 25)
            
        }
    }
    
    private var headingContent: some View {
        VStack {
            Text("Inspection")
                .font(.bold(20))
                .foregroundColor(Color.Blue.THEME)
            
            Text(inspectionType.auditItemTitle)
                .font(.regular(16))
                .foregroundColor(Color.Grey.GUNMENTAL)
                .padding(.bottom, 50)
        }
    }
    
    private var specifyProjectToggleBar: some View {
        VStack(alignment:.leading, spacing:0) {
            VStack {
                HStack {
                    Text("Specify Facility / Project")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(13.5))
                    
                    Spacer()
                    
                    if !isViewOnly {
                        Button {
                            withAnimation {
                                isGroupView.toggle()
                            }
                        } label: {
                            Image(isGroupView ? IC.ACTIONS.TOGGLE_ON : IC.ACTIONS.TOGGLE_OFF)
                        }
                    }
                
                }
                .disabled(isViewOnly)
                .padding(.horizontal, 17)
                
                if isGroupView {
                    VStack {
                        if !isViewOnly {
                            LeftAlignedHStack(
                                Text("SELECT PROJECT")
                                    .foregroundColor(Color.Grey.STEEL)
                                    .font(.regular(12.5))
                            )
                        }
                        
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
                        
                        if !isViewOnly {
                            LeftAlignedHStack(
                                Button(action: {
                                    viewControllerHolder?.present(style: .overCurrentContext) {
                                        NFGroupListContentView(isFromViewGroup: false, isFromCreateObservation: true, isActive: $isGroupActive, groupData: $groupData)
                                    }
                                }, label: {
                                    Text("Select")
                                        .foregroundColor(Color.Blue.THEME)
                                        .font(.medium(13))
                                })
                            )
                            .padding(.top, 15)
                        }
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
    }
    
    private var formView: some View {
        VStack(spacing:17) {
            Group {
                ThemeTextFieldView(text: $identificationNumber, title: "EQUIPMENT DESCRIPTION/ MODEL NUMBER/ PLATE NUMBER/ IDENTIFICATION NUMBER :", placeholder: "", isMandatoryField: true)
                ThemeTextFieldView(text: $inspectedBy, title: "INSPECTED BY", disabled: true)
                ThemeTextFieldView(text: $location, title: "LOCATION", isMandatoryField: false)
                if isViewOnly {
                    VStack {
                        HStack(spacing: 2) {
                            Text("DESCRIPTION")
                                .foregroundColor(Color.Blue.GREY)
                                .font(.regular(12))
                        
                                
                        
                            Spacer()
                        }
                        
                        Text(description)
                            .leftAlign()
                            .font(.regular(14))
                            .foregroundColor(Color.Indigo.DARK)
                            .padding(.vertical, 10)
                        
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color.Silver.TWO)
                    }
                } else {
                    ThemeTextFieldView(text: $description, title: "DESCRIPTION", isMandatoryField: false)
                }
                
                InputFieldView(title: "EQUIPMENT SOURCE", showTitle: true, isOptionalTextView: false ,isDividerShown: true, isMandatoryField: true) {
                    equipmentSourceInputs
                }
                
                
                ThemeTextFieldView(text: $rentalOrSubContractor, title: "IF RENTAL OR SUBCONTRACTOR", isMandatoryField: isRentalOrSubContractor)
                
                
                
                staticEquipmentView
                
                notesView
            }
            .disabled(isViewOnly)
            
            LeftAlignedHStack(
                Text(isViewOnly ? "IMAGES" : "UPLOAD IMAGES")
                    .foregroundColor(Color.Blue.GREY)
                    .font(.regular(12))
            )
            
            
            if isViewOnly {
                if let imageDescription = viewModel.inspectionView?.images, imageDescription.count > 0 {
                    ForEach(0..<imageDescription.count, id: \.self) { index in
                        ImageView(count: index + 1, imageDescription: imageDescription[index], imageData: $imageData, showImages: $showImage)
                            .padding(.top, 5)
                    }
                } else {
                    VStack {
                        Text("No Images Found")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(13))
                    }
                    .frame(height: 93.5)
                }
            } else {
                imageView
            }
            
            
            if imagesDatas.endIndex < 6 && !isViewOnly {
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
            if !isViewOnly {
                ButtonWithLoader(action: {createInspection()}, title: "Publish", width: screenWidth - ( 25 * 2 ), height: 52, isLoading: .constant(false))
            }
        }
        .padding(.vertical, 20)
    }
    
    
    private var imageView: some View {
        ForEach(imagesDatas.indices, id: \.self) { index in
            CreateInspectionImageView(
                imageUrlGenerated: { url in
                    imagesDatas[index].image = url
                }, descriptionChanged: { description in
                    imagesDatas[index].description = description
                }, minusButtonTapped: {
                    if !isViewOnly {
                        var images = imagesDatas
                        images.remove(at: index)
                        imagesDatas = images
                        imageListId = UUID()
                    }
                }, isViewOnly: isViewOnly, viewModel: CreateInspectionImageViewModel(item: imagesDatas[index], index: index),
                showImage: $showImage, imageUrlData: $imageData)
        }
        .id(imageListId)
    }
    
    private var equipmentSourceInputs: some View {
        HStack(spacing:10) {
            ForEach(EquipmentSource.allCases, id: \.self) { source in
                Button(action: {
                    selectedEquipmentSource = (selectedEquipmentSource == source) ? nil : source
                    isRentalOrSubContractor = (source == .rental || source == .subcontractor)
                }) {
                    HStack(spacing:10) {
                        Image(selectedEquipmentSource == source ? IC.ACTIONS.GREEN_RADIO_BUTTON.ON : IC.ACTIONS.GREEN_RADIO_BUTTON.OFF)
                        Text(source.title)
                            .font(.medium(12))
                            .foregroundColor(Color.Blue.GREY)
                    }
                }
                
                if source != EquipmentSource.allCases.last {
                    Spacer()
                }
            }
        }
    }
    
    private var staticEquipmentView: some View {
        VStack(spacing:10) {
            HStack(spacing: 2){
                Text("STATIC EQUIPMENT")
                    .foregroundColor(Color.Blue.GREY)
                    .font(.regular(12))
                    
                
                Text("*")
                    .foregroundColor(Color.Red.CORAL)
                    .font(.regular(12))
                
            }
            .padding(.bottom, 10)
            .leftAlign()
            
            ForEach($viewModel.staticEquipmentData) {$data in
                VStack(spacing:10) {
                    Text(data.title)
                        .leftAlign()
                        .font(.medium(14))
                    HStack(spacing:10) {
                        Group {
                            Image(data.selectedValue == .yes ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            Text("Yes")
                                .foregroundColor(Color.Blue.GREY)
                                .font(.regular(12))
                        }
                        .onTapGesture {
                            data.selectedValue = .yes
                        }
                        
                        Spacer()
                        Group {
                            Image(data.selectedValue == .no ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            Text("No")
                                .foregroundColor(Color.Blue.GREY)
                                .font(.regular(12))
                        }
                        .onTapGesture {
                            data.selectedValue = .no
                        }
                        Spacer()
                        Group {
                            Image(data.selectedValue == .notApplicable ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            Text("Not Applicable")
                                .foregroundColor(Color.Blue.GREY)
                                .font(.regular(12))
                        }
                        .onTapGesture {
                            data.selectedValue = .notApplicable
                        }
                        Spacer()
                    }
                    Divider()
                }
                
            }
            
        }
    }
    
    private var notesView: some View {
        VStack(spacing:10) {
            Text("NOTES")
                .foregroundColor(Color.Blue.GREY)
                .font(.regular(12))
                .leftAlign()
            
            VStack(spacing:10) {
                if isViewOnly {
                    Text(notes)
                        .font(.regular(14))
                        .leftAlign()
                        .foregroundColor(Color.Indigo.DARK)
                        .padding()
                } else {
                    ThemeTextFieldView(text: $notes, title: "", placeholder: "", showTitle: false, isDividerShown: false)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 85)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
            
            
        }
    }
    
    func createInspection() {
        viewModel.addInspection(inspectionTypeId: inspectionType.auditItemId,modelNumber: identificationNumber, inspectedBy: inspectedBy, location: location, description: description, equipmentSource: selectedEquipmentSource, subContractor: rentalOrSubContractor, staticEquipment: viewModel.staticEquipmentData, groupData: groupData, notes: notes, image: imagesDatas) { completed in
            isListChanged = true
            showSuccessAlert.toggle()
        }
    }
    
    func generatePdf() {
        viewModel.generatePdf { completed in
            savePdf(urlString: viewModel.pdfUrl)
        }
    }
    
    func savePdf(urlString:String) {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let pdfNameFromUrl = "ALNASR- \(Date().timeIntervalSince1970).pdf"
        let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
        do {
            try pdfData?.write(to: actualPath, options: .atomic)
            viewModel.toast = "pdf successfully saved!".successToast
        } catch {
            viewModel.toast = Toast.alert(subTitle: "Pdf could not be saved")
        }
    }
    
    func showActivityViewController(activities: [Any]) {
        
        let shareController: UIActivityViewController = {
            let controller = UIActivityViewController(activityItems: activities, applicationActivities: nil)
            
            controller.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.openInIBooks,
                UIActivity.ActivityType.message,
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.copyToPasteboard,
                UIActivity.ActivityType.mail,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.markupAsPDF,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
                UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
            
            return controller
        }()
        
        viewControllerHolder?.present(shareController, animated: true, completion: {
        })
    }
}

extension CreateEquipmentStaticView {
    struct ImageView: View {
        var count: Int
        var imageDescription: ImageData
        @Binding var imageData: String?
        @Binding var showImages: Bool
        
        var body: some View {
            VStack {
                VStack {
                    LeftAlignedHStack(
                        Text("Image \(count)")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.medium(13))
                    )
                    
                    WebUrlImage(url: imageDescription.image?.url)
                        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 93.5, alignment: .center)
                        .cornerRadius(10)
                        .clipped()
                        .padding(.top, 13.5)
                        .onTapGesture {
                            imageData = imageDescription.image
                            showImages.toggle()
                        }
                    
                    LeftAlignedHStack(
                        Text("Description")
                            .foregroundColor(Color.Grey.BLUEY_GREY)
                            .font(.regular(12))
                    )
                        .padding(.top, 20.5)
                    
                    LeftAlignedHStack(
                        Text(imageDescription.description ?? "")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.light(12))
                            .padding(.top, 13.5)
                    )
                }
                .padding(.vertical, 23.5)
                .padding(.horizontal, 22)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
        }
    }
}

