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
    @State private var successAlertforDraft: Bool = false
    @State private var identificationNumber: String = ""
    @State private var inspectedBy: String = ""
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var selectedEquipmentSource: EquipmentSource?
    @State private var rentalOrSubContractor: String = ""
    @State private var notes: String = ""
    @State private var showDatePicker: Bool = false
    @State var imagesDatas: [ImageData] = []
    @State var imageListId = UUID()
    @State var showImage: Bool = false
    @State private var imageData: String?
    @State var imageCount: Int = 1
    @State var inspectionDate: Date?
    @State var showBackButtonalert: Bool = false
    @State var showSuccessAlert: Bool = false
    @State var showShareDocumentAlert: Bool = false
    
    @State var isRentalOrSubContractor: Bool = false
    @State var disablePublish: Bool = false
    @StateObject var viewModel: CreateEquipmentStaticViewModel
    
    @Binding var isListChanged: Bool
    
    var inspectionType: AuditsInspectionsList
    var isViewOnly: Bool = false
    
    private var isShowingContent: Bool {
        inspectionType.auditItemId == 4 || inspectionType.auditItemId == 5 || inspectionType.auditItemId == 6 || inspectionType.auditItemId == 7 || inspectionType.auditItemId == 8
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    contentView
                    
                }
                .onAppear {
                    
                    if !isViewOnly {
                        viewModel.fetchStaticEquipmentData()
                        self.inspectedBy = UserManager.getLoginedUser()?.name ?? ""
                    }
                    viewModel.fetchInspectionDetails{ inspection in
                        if let inspection {
                            DispatchQueue.main.async {
                                setInspections(inspection)
                            }
                        }
                    }
                }
                
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
                        HStack(spacing: 5) {
                            if viewModel.isDownloading {
                                CircularDownloadProgressView(progress: viewModel.downloadProgress)
                                    .padding()
                            } else {
                                Button {
                                    generatePdf()
                                } label: {
                                    Text("generate_pdf".localizedString())
                                        .foregroundColor(Color.white)
                                        .font(.medium(12))
                                        .frame(width: 125, height: 33.5)
                                        .background(Color.Blue.THEME)
                                        .cornerRadius(16.75)
                                }
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
        .onChange(of: showSuccessAlert) { newValue in
            /// Dismissing the current view when close button is tapped in success alert picker
            if !newValue {
                viewControllerHolder?.dismiss(animated: true, completion: nil)
            }
            
        }
        .onChange(of: viewModel.showAlertForDateChange) { newValue in
            if newValue {
                disablePublish = true
            }
        }
        .pickerViewerOverlay(viewerShown: $showSuccessAlert, title: "inspection_created".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("inspection_created_successfully".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        NotificationCenter.default.post(name: .UPDATE_DRAFT, object: nil)
                        NotificationCenter.default.post(name: .UPDATE_INSPECTIONS_LIST, object: nil)
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
        .overlay(
            Group {
                if viewModel.pdfLoading {
                    PDFLoadingOverlay()

                }
            }
        )
        .overlay(ShareObservationAlertView(viewerShown: $showShareDocumentAlert) { isPDFSelected in
            
            if !isPDFSelected {
                let message = viewModel.getShareMessage() // full inspection report
                showActivityViewController(activities: [message as Any])
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
        .pickerViewerOverlay(viewerShown: $successAlertforDraft, title: "draft_saved".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("inspection_draft_success".localizedString())
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
        //        .pickerViewerOverlay(viewerShown: $viewModel.showAlertForDateChange, title: "Questions Changed".localizedString()) {
        //
        //            VStack {
        //                LeftAlignedHStack(
        //                    Text("The questions have been updated, make sure before publishing or discard the draft")
        //                        .foregroundColor(Color.Indigo.DARK)
        //                        .font(.regular(14))
        //                )
        //
        //                HStack{
        //                    Spacer()
        //
        //                    Button {
        //                        viewModel.showAlertForDateChange = false
        //                    } label: {
        //                        Text("Okay")
        //                            .foregroundColor(Color.white)
        //                            .font(.regular(12))
        //                    }
        //                    .frame(width: 80, height: 35)
        //                    .background(Color.Blue.THEME)
        //                    .cornerRadius(17.5)
        //                }
        //                .padding(.vertical, 15)
        //                .padding(.trailing, 15)
        //            }
        //
        //        }
        .overlay(
            DatePickerView(selectedDate: $inspectionDate, showDatePicker: $showDatePicker)
                .ignoresSafeArea()
        )
        
        
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
            Text("inspection".localizedString())
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
                    Text("specify_facility_or_project".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(13.5))
                    
                    Spacer()
                    
                    if !isViewOnly {
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
                    }
                    
                }
                .disabled(isViewOnly)
                .padding(.horizontal, 17)
                
                if isGroupView {
                    VStack {
                        if !isViewOnly {
                            LeftAlignedHStack(
                                Text("select_a_project".localizedString())
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
                if isShowingContent {
                    ThemeTextEditorView(text: $identificationNumber, title: "identification_number".localizedString(), disabled: isViewOnly, keyboardType: .default, isMandatoryField: true, limit: nil, placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: false, isPlaceHolderShown: false)
                }
                
                ThemeTextEditorView(text: $inspectedBy, title: "inspected_by".localizedString(), disabled: true, keyboardType: .default, isMandatoryField: true, limit: nil, placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: false)
                
                
                ThemeTextEditorView(text: $location, title: "location".localizedString(), disabled: isViewOnly, keyboardType: .default, isMandatoryField: false, limit: nil, placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: false)
                
                
                ThemeDatePickerView(date: $inspectionDate, title: "date".localizedString(), placeholder: "enter_inspection_date".localizedString(), showDatePicker: $showDatePicker)
                
                if isViewOnly {
                    VStack {
                        HStack(spacing: 2) {
                            Text("description".localizedString())
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
                    
                    ThemeTextEditorView(text: $description, title: "description".localizedString(), disabled: isViewOnly, keyboardType: .default, isMandatoryField: false, limit: nil, placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: false)
                }
                
                if isShowingContent {
                    
                    InputFieldView(title: "equipment_source".localizedString(), showTitle: true, isOptionalTextView: false ,isDividerShown: true, isMandatoryField: true) {
                        equipmentSourceInputs
                    }
                    
                    
                    ThemeTextEditorView(text: $rentalOrSubContractor, title: "if_rental".localizedString(), disabled: isViewOnly, keyboardType: .default, isMandatoryField: isRentalOrSubContractor, limit: nil, placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: false)
                    
                }
                
                staticEquipmentView
                
                notesView
            }
            .disabled(isViewOnly)
            
            LeftAlignedHStack(
                Text(isViewOnly ? "images".localizedString() : "upload_images".localizedString())
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
                        Text("no_images_found".localizedString())
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
                    let index = imagesDatas.endIndex
                    imagesDatas.append(ImageData.dummy(imageCount: index + 1))
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
            
            if disablePublish {
                Text("questions_updated_warning".localizedString())
            .font(.lightItalic(10))
            .foregroundColor(Color.Red.LIGHT)
            .multilineTextAlignment(.center)
            }
            
            if !isViewOnly {
                ButtonWithLoader(action: {createInspection()}, title: "publish".localizedString(), width: screenWidth - ( 25 * 2 ), height: 52, isLoading: .constant(false))
                    .disabled(disablePublish || viewModel.staticEquipmentData.isEmpty)
                    .opacity(disablePublish || viewModel.staticEquipmentData.isEmpty ? 0.5 : 1)
                
                Button {
                    saveAsDraft()
                } label: {
                    Text("save_as_draft".localizedString())
                        .foregroundColor(Color.Orange.PINK)
                        .font(.regular(15))
                }
                .disabled(disablePublish || viewModel.staticEquipmentData.isEmpty)
                .opacity(disablePublish || viewModel.staticEquipmentData.isEmpty ? 0.5 : 1)
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
                Text((inspectionType.auditItemTitle + " " + "fields".localizedString()).uppercased())
                    .foregroundColor(Color.Blue.GREY)
                    .font(.regular(12))
                    
                
                Text("*")
                    .foregroundColor(Color.Red.CORAL)
                    .font(.regular(12))
                
            }
            .padding(.bottom, 10)
            .leftAlign()
            
            
            if viewModel.staticEquipmentData.isEmpty {
                if let error = viewModel.error {
                    ErrorRetryView(
                        retry: {
                            viewModel.fetchStaticEquipmentData()
                        },
                        title: "error".localizedString(),
                        message: viewModel.toast.subTitle ?? error.localizedDescription,
                        isDarkMode: false,
                        isError: true
                    )
                } else {
                    // No error, but also no data
                    ErrorRetryView(
                        retry: {
                            viewModel.fetchStaticEquipmentData()
                        },
                        title: "no_questions_found".localizedString(),
                        message: "no_questions_found_message".localizedString(),
                        isDarkMode: false,
                        isError: false
                    )
                }
            }

            
            ForEach($viewModel.staticEquipmentData) {$data in
                VStack(spacing:10) {
                    Text(data.title)
                        .leftAlign()
                        .font(.medium(14))
                        .foregroundColor(Color.Black.DARK)
                    
                    HStack(spacing:10) {
                        Group {
                            Image(data.selectedValue == .yes ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            Text("yes".localizedString())
                                .foregroundColor(Color.Blue.GREY)
                                .font(.regular(12))
                        }
                        .onTapGesture {
                            data.selectedValue = .yes
                        }
                        
                        Spacer()
                        Group {
                            Image(data.selectedValue == .no ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            Text("no".localizedString())
                                .foregroundColor(Color.Blue.GREY)
                                .font(.regular(12))
                        }
                        .onTapGesture {
                            data.selectedValue = .no
                        }
                        Spacer()
                        Group {
                            Image(data.selectedValue == .notApplicable ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            Text("not_applicable".localizedString())
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
            Text("notes".localizedString())
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
                    
                    ThemeTextEditorView(text: $notes, title: "", disabled: isViewOnly, keyboardType: .default, isMandatoryField: false, limit: nil, placeholderColor: Color.Grey.GUNMENTAL.opacity(0.25), isTitleCapital: false, isDividerShown: false)
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
        viewModel.addInspection(inspectionTypeId: inspectionType.auditItemId,modelNumber: identificationNumber, inspectedBy: inspectedBy, location: location, inspectionDate: inspectionDate, description: description, equipmentSource: selectedEquipmentSource, subContractor: rentalOrSubContractor, staticEquipment: viewModel.staticEquipmentData, groupData: groupData, notes: notes, image: imagesDatas, isShowingContent: isShowingContent) { completed in
            isListChanged = true
            showSuccessAlert.toggle()
        }
    }
    
    func generatePdf() {
        viewModel.generatePdf { completed in
            viewModel.savePdfWithProgress(urlString: viewModel.pdfUrl, fileName: "QualityExpertise - Audits & Inspections(\(viewModel.inspectionView?.id ?? -1)).pdf")
        }
    }
    
    func saveAsDraft() {
        viewModel.saveAsDraft(inspectionType: inspectionType, modelNumber: identificationNumber, inspectedBy: inspectedBy, location: location, inspectionDate: inspectionDate, description: description, equipmentSource: selectedEquipmentSource, subContractor: rentalOrSubContractor, staticEquipment:viewModel.staticEquipmentData , groupData: groupData, notes: notes, image: imagesDatas, isShowingContent: isShowingContent){ completed in
            if completed {
                successAlertforDraft.toggle()
            }
        }
    }
    
    func setInspections(_ inspections: Inspections) {
        withAnimation {
            self.isProjectOption = (inspections.facilities != nil)
            self.isGroupView = (inspections.facilities != nil)
            self.isGroupActive = (inspections.facilities != nil)
            self.groupData = inspections.facilities
            self.identificationNumber = inspections.modelNumber ?? ""
            self.inspectedBy = inspections.inspectedBy
            self.location = inspections.location
            self.inspectionDate = inspections.inspectionDate?.repoDate(inputFormat: Constants.DateFormat.REPO_DATE, local: LocalizationService.shared.language.local)
            self.description = inspections.description
            viewModel.staticEquipmentData = inspections.staticEquipment ?? []
            self.selectedEquipmentSource = inspections.equipmentSource
            self.rentalOrSubContractor = inspections.subContractor ?? ""
            self.notes = inspections.notes
            self.imagesDatas = inspections.images ?? []
            self.imageCount = inspections.images?.count ?? 0
        }
    }
    
    func savePdf(urlString:String) {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let pdfNameFromUrl = "QualityExpertise - Audits & Inspections(\(viewModel.inspectionView?.id ?? -1)).pdf"
        let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
        do {
            try pdfData?.write(to: actualPath, options: .atomic)
            viewModel.toast = "pdf_saved_success".localizedString().successToast
        } catch {
            viewModel.toast = Toast.alert(subTitle: "pdf_save_failed".localizedString())
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
                        Text(String(format: "image_with_count".localizedString(), count))
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
                        Text("description".localizedString())
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

