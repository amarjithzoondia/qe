//
//  CreateIncidentView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

import SwiftUI

struct CreateIncidentView: View {
    internal init(incident: Incident?, draftIncident: Incident? = nil, isViewOnly: Bool = false, onSuccess: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CreateIncidentViewModel(incident: incident, draftIncident: draftIncident))
        self.isViewOnly = isViewOnly
        self.onSuccess = onSuccess
    }
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode

    @State private var isProjectOption: Bool = false
    @State private var isGroupView: Bool = false
    @State private var isGroupActive: Bool = false
    @State private var groupData: GroupData? = nil
    @State private var reportedBy: String = ""
    @State private var incidentDate: Date?
    @State private var incidentTime: Date?
    @State private var incidentLocation: String = ""
    @State private var selectedIncidentType: [Int] = []
    
    @State private var description: String = ""
    @State private var corrections: String = ""
    
    @State private var isInjuredTrue: Bool = false
    @State private var isInjuredFalse: Bool = false
    
    @State private var employeeName: String = ""
    @State private var employeeCode: String = ""
    @State private var employeeCompany: String = ""
    @State private var employeeProfession: String = ""
    
    @State private var manualEmployees: [Employee] = []
    @State private var bulkEmployees: [Employee] = []
    private var injuredEmployees: [Employee] {
        manualEmployees + bulkEmployees
    }
    
    @State private var isDropDownShowing: Bool = false
    @State private var isSelectionInProgress: Bool = false   // 👈 flag

    @State private var imagesDatas: [ImageData] = []
    @State private var imageListId = UUID()
    @State private var showImage: Bool = false
    @State private var imageData: String?
    @State private var imageCount: Int = 1
    
    @State private var showBackButtonalert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showShareDocumentAlert: Bool = false
    @State private var successAlertforDraft: Bool = false
    @State private var groupSpecifiedAlert: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    
    @StateObject var viewModel: CreateIncidentViewModel
    
    let isViewOnly: Bool
    var onSuccess: (() -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                contentView
                    .onAppear {
                        if !isViewOnly {
                            self.reportedBy = UserManager.getLoginedUser()?.name ?? ""
                        }
                        viewModel.fetchEmployees()
                        viewModel.fetchIncidentDetails() { incident in
                            if let incident {
                                DispatchQueue.safeAsyncMain {
                                    setIndicent(incident: incident)
                                }
                            }
                        }
                    }
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
                
            }
            .navigationBarTitle(isViewOnly ? "" : "incident_notification".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    if isViewOnly {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } else {
                        showBackButtonalert.toggle()
                    }
                })
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isViewOnly, let incident = viewModel.incident {
                        HStack(spacing: 5){
                            if viewModel.isDownloading {
                                CircularDownloadProgressView(progress: viewModel.downloadProgress)
                                    .padding()
                            } else {
                                Button {
                                    generatePdf(incident: incident)
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
        .overlay(
            Group {
                if viewModel.pdfLoading {
                    PDFLoadingOverlay()

                }
            }
        )
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
        .onChange(of: incidentDate) { newValue in
            incidentTime = nil
        }
        .overlay(
            DatePickerView(selectedDate: $incidentDate, showDatePicker: $showDatePicker)
                .ignoresSafeArea()
        )
        .overlay(
            TimePickerView(selectedTime: $incidentTime, showTimePicker: $showTimePicker, selectedDate: incidentDate)
                .ignoresSafeArea()
        )
        .pickerViewerOverlay(viewerShown: $showSuccessAlert, title: "incident_created".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("incident_created_success".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
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
        .overlay(ShareObservationAlertView(viewerShown: $showShareDocumentAlert) { isPDFSelected in
            if !isPDFSelected, let incident = viewModel.incident {
                let message = viewModel.getShareMessage(incident: incident)
                showActivityViewController(activities: [message])
            } else {
                if let incident = viewModel.incident {
                    viewModel.generatePdf(incident: incident) { completed in
                        viewModel.sharePdf(urlString: viewModel.pdfUrl, completion: { pdfData in
                            showActivityViewController(activities: [pdfData as Any])
                        })
                    }
                }
            }
        })
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
        .pickerViewerOverlay(viewerShown: $successAlertforDraft, title: "draft_saved".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("incident_saved_as_draft".localizedString())
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
        .pickerViewerOverlay(viewerShown: $groupSpecifiedAlert, title: "draft_saved".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("incident_saved_as_draft_without_group".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: {
                            onSuccess?()
                        })
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
        
        
        
    }
    
    private var headingContent: some View {
        VStack {
            Text("incidents_title".localizedString())
                .font(.bold(20))
                .foregroundColor(Color.Blue.THEME)
            
            Text("view_details".localizedString())
                .font(.regular(16))
                .foregroundColor(Color.Grey.GUNMENTAL)
                .padding(.bottom, 50)
        }
    }
    
    
    private var contentView: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                
                if isViewOnly {
                    headingContent
                        .padding(.top, 30)
                }
                
                specifyProjectToggleBar
                    .padding(.top, isViewOnly ? 0 : 30)
                    .padding(.horizontal, 25)
                    .disabled(isViewOnly)
                
                formView
                    .padding(.horizontal, 25)
                
            }
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
                                    bulkEmployees.removeAll()
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
                
                ThemeTextEditorView(text: $reportedBy, title: "reported_by".localizedString().uppercased(), disabled: true, isMandatoryField: true)
                
                ThemeDatePickerView(date: $incidentDate, title: "incident_date".localizedString().uppercased(), placeholder: "enter_incident_date".localizedString().uppercased(), showDatePicker: $showDatePicker)
                    .disabled(isViewOnly)
                
                ThemeDatePickerView(date: $incidentTime, title: "incident_time".localizedString().uppercased(), placeholder: "enter_incident_time".localizedString().uppercased(), isTimePicker: true, showDatePicker: $showTimePicker)
                    .frame(width: screenWidth/2)
                    .leftAlign()
                    .disabled(isViewOnly)
                
                
                ThemeTextEditorView(text: $incidentLocation, title: "location".localizedString(), disabled: isViewOnly, isMandatoryField: false)
                
                incidentTypeView
                    .disabled(isViewOnly)
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
                
                injuredPersonView
                    .disabled(isViewOnly)
                
                if isInjuredTrue {
                    if !injuredEmployees.isEmpty {
                        employeeDeatilesView
                    }
                    if !isViewOnly {
                        addinjuredPersonView
                    }
                }
                
                decriptionView
                    .disabled(isViewOnly)
                
                correctionView
                    .disabled(isViewOnly)
                
                
            }
            
            
            LeftAlignedHStack(
                Text(isViewOnly ? "images".localizedString() : "upload_images".localizedString())
                    .foregroundColor(Color.Blue.GREY)
                    .font(.regular(12))
            )
            
            
            if isViewOnly {
                if imagesDatas.count > 0 {
                    ForEach(0..<imagesDatas.count, id: \.self) { index in
                        ImageView(count: index + 1, imageDescription: imagesDatas[index], imageData: $imageData, showImages: $showImage)
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
            if !isViewOnly {
                ButtonWithLoader(action:createIncident, title: "publish".localizedString(), width: screenWidth - ( 25 * 2 ), height: 52, isLoading: .constant(false))
                
                Button {
                    saveAsDraft()
                } label: {
                    Text("save_as_draft".localizedString())
                        .foregroundColor(Color.Orange.PINK)
                        .font(.regular(15))
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    
    
    
    private var imageView: some View {
        ForEach(imagesDatas.indices, id: \.self) { index in
            CreateIncidentImageView(
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
                }, isViewOnly: isViewOnly, viewModel: CreateIncidentImageViewModel(item: imagesDatas[index], index: index),
                showImage: $showImage, imageUrlData: $imageData)
        }
        .id(imageListId)
    }
    
    
    
    
    
    private var decriptionView: some View {
        VStack(spacing:10) {
            Text("description".localizedString())
                .foregroundColor(Color.Blue.GREY)
                .font(.regular(12))
                .leftAlign()
            
            VStack(spacing:10) {
                if isViewOnly {
                    Text(description)
                        .font(.regular(14))
                        .leftAlign()
                        .foregroundColor(Color.Indigo.DARK)
                        .padding()
                } else {
                    
                    ThemeTextEditorView(text: $description, title: "", isDividerShown: false, isPlaceHolderShown: false)
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
    
    private var correctionView: some View {
        VStack(spacing:10) {
            Text("immediate_corrections".localizedString())
                .foregroundColor(Color.Blue.GREY)
                .font(.regular(12))
                .leftAlign()
            
            VStack(spacing:10) {
                if isViewOnly {
                    Text(corrections)
                        .font(.regular(14))
                        .leftAlign()
                        .foregroundColor(Color.Indigo.DARK)
                        .padding()
                } else {
                    
                    ThemeTextEditorView(text: $corrections, title: "", isDividerShown: false, isPlaceHolderShown: false)
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
    
    private var incidentTypeView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            HStack(spacing: 2) {
                Text("incident_type".localizedString().uppercased())
                    .foregroundColor(Color.Blue.GREY)
                    .font(.regular(12))
                
                Text("*")
                    .foregroundColor(Color.Red.CORAL)
                    .font(.regular(12))
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Incident type list
                ForEach(IncidentType.allCases, id: \.self) { type in
                    HStack(spacing: 8) {
                        if selectedIncidentType.contains(type.id) {
                            Image(IC.ACTIONS.CHECKBOX_ON)
                                .resizable()
                                .frame(width: 22, height: 22)
                        } else {
                            Image(IC.ACTIONS.CHECKBOX_OFF)
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                        Text(type.title.uppercased())
                            .foregroundColor(Color.Blue.GREY)
                            .font(.regular(12))
                        Spacer()
                    }
                    .onTapGesture {
                        if selectedIncidentType.contains(type.id) {
                            selectedIncidentType.removeAll{ $0 == type.id }
                        } else {
                            selectedIncidentType.append(type.id)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
    }
    
    private var injuredPersonView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("injured_person_details".localizedString())
                .foregroundColor(Color.Blue.GREY)
                .font(.regular(12))
                .leftAlign()
            
            HStack(spacing: 10) {
                HStack(spacing: 2) {
                    Text("are_there_injured".localizedString())
                        .foregroundColor(Color.Blue.GREY)
                        .font(.regular(12))
                        .padding(.vertical, 10)
                    
                    Text("*")
                        .foregroundColor(Color.Red.CORAL)
                        .font(.regular(12))
                }
                
                HStack(spacing: 8) {
                    Image(isInjuredTrue ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                        .frame(width: 22, height: 22)
                    Text("yes".localizedString().uppercased())
                        .foregroundColor(Color.Blue.GREY)
                        .font(.regular(12))
                        .padding(.vertical, 10)
                }
                .onTapGesture {
                    withAnimation {
                        isInjuredTrue.toggle()
                        isInjuredFalse = false
                        clearAllEmployees()
                    }
                }
                
                HStack(spacing: 8) {
                    Image(isInjuredFalse ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                        .frame(width: 22, height: 22)
                    Text("no".localizedString().uppercased())
                        .foregroundColor(Color.Blue.GREY)
                        .font(.regular(12))
                        .padding(.vertical, 10)
                }
                .onTapGesture {
                    withAnimation {
                        isInjuredFalse.toggle()
                        isInjuredTrue = false
                        clearAllEmployees()
                    }
                }
            }
            .leftAlign()
        }
    }
    
    func clearAllEmployees() {
        manualEmployees.removeAll()
        bulkEmployees.removeAll()
    }
    
    private var addinjuredPersonView: some View {
        VStack(spacing: 10) {
            ThemeTextEditorView(text: $employeeCode, title: "employee_code".localizedString(), isMandatoryField: true)
            .onChange(of: employeeCode) { newValue in
                if isSelectionInProgress {
                    // Reset flag, don’t reopen dropdown
                    isSelectionInProgress = false
                } else {
                    // User typed
                    isDropDownShowing = !newValue.isEmpty
                }
            }
            
            if isDropDownShowing {
                let filteredEmployees = viewModel.employees.filter { employee in
                    if let empCode = employee.employeeCode, !empCode.isEmpty {
                        return empCode.lowercased().contains(employeeCode.lowercased())
                    }
                    return false
                }
                
                
                if !filteredEmployees.isEmpty {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 0) {
                            ForEach(filteredEmployees, id: \.employeeCode) { employee in
                                let isSelected = manualEmployees.contains { $0.employeeCode == employee.employeeCode }
                                employeeScrollViewRow(employee: employee, isSelected: isSelected)
                                    .onTapGesture {
                                        if isSelected {
                                            viewModel.toast = Toast.alert(title: "alert".localizedString(), subTitle: "employee_already_added".localizedString())
                                        }
                                        else {
                                            isSelectionInProgress = true
                                            
                                            self.employeeCode = employee.employeeCode ?? "-"
                                            self.employeeName = employee.employeeName
                                            self.employeeCompany = employee.companyName ?? "-"
                                            self.employeeProfession = employee.profession ?? "-"
                                            
                                            // hide dropdown
                                            self.isDropDownShowing = false
                                        }
                                    }
                            }
                        }
                    }
                    .frame(height: 300)
                }
            }
            
            ThemeTextEditorView(
                text: $employeeName,
                title: "employee_name".localizedString().uppercased(),
                isMandatoryField: true
            )
            ThemeTextEditorView(
                text: $employeeCompany,
                title: "company_name".localizedString().uppercased(),
                isMandatoryField: true
            )
            ThemeTextEditorView(
                text: $employeeProfession,
                title: "profession".localizedString().uppercased(),
                isMandatoryField: true
            )
            
            HStack(spacing: 10) {
                Button {
                    addEmployee()
                } label: {
                    HStack{
                        Image(IC.ACTIONS.PLUS)
                            .foregroundColor(Color.Green.DARK_GREEN)
                        
                        Text("add_employee".localizedString())
                            .foregroundColor(Color.Blue.THEME)
                            .font(.regular(12))
                        
                        Spacer()
                    }
                }
                
                Spacer()
                if let groupData {
                    Button {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            BulkUploadEmployeeView(groupData: groupData, employees: $bulkEmployees)
                                .localize()
                        }
                    } label: {
                        HStack{
                            Image(IC.ACTIONS.PLUS)
                                .foregroundColor(Color.Green.DARK_GREEN)
                            
                            Text("bulk_upload_employees".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        }
                    }
                }
                
            }
            .padding(.vertical, 10)
            
        }
    }
    
    private func employeeScrollViewRow(employee: Employee, isSelected: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                    .resizable()
                    .frame(width: 48, height: 48) // Reduced size for better alignment
                    .padding(.leading, 8)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(employee.employeeName)
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(14))
                                .lineLimit(1)
                            
                            Text(employee.companyName ?? Constants.NOTHING)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                            
                            Text(employee.profession ??  Constants.NOTHING)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Spacer()
                            Text(employee.employeeCode ?? Constants.NOTHING)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            Divider()
                .background(Color.Blue.VERY_LIGHT)
                .frame(height: 0.5)
        }
    }
    
    private func displayText(_ value: String?) -> String {
        guard let val = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !val.isEmpty else {
            return Constants.HYPHEN
        }
        return val.uppercased()
    }
    
    private var employeeDeatilesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Table Header
                HStack {
                    Group {
                        Text("employee_code".localizedString().uppercased()).bold().frame(width: 150, alignment: .leading)
                        Text("employee_name".localizedString().uppercased()).bold().frame(width: 150, alignment: .leading)
                        Text("company_name".localizedString().uppercased()).bold().frame(width: 150, alignment: .leading)
                        Text("profession".localizedString().uppercased()).bold().frame(width: isViewOnly ? 150 : 300, alignment: .leading)
                    }
                    .font(.regular(12))
                    .foregroundColor(Color.white)
                    
                }
                .padding(10)
                .background(Color.Blue.THEME)
                
                Divider()
                
                
                // Table Rows
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(injuredEmployees.indices, id: \.self) { index in
                        let emp = injuredEmployees[index]
                        HStack {
                            Group {
                                Text(displayText(emp.employeeCode)).frame(width: 150, alignment: .leading)
                                Text(displayText(emp.employeeName)).frame(width: 150, alignment: .leading)
                                Text(displayText(emp.companyName)).frame(width: 150, alignment: .leading)
                                Text(displayText(emp.profession)).frame(width: 150, alignment: .leading)
                            }
                            .font(.regular(12))
                            .foregroundColor(Color.black)
                            if !isViewOnly {
                                Button {
                                    bulkEmployees.removeAll { $0.id == emp.id }
                                    manualEmployees.removeAll { $0.employeeCode == emp.employeeCode }
                                } label: {
                                    Image(IC.ACTIONS.MINUS)
                                    
                                }
                                .frame(width: 100, alignment: .center)
                            }
                        }
                        .padding(8)
                        Divider()
                    }
                }
            }
        }
    }
    
    func addEmployee() {
        if employeeName.isEmpty || employeeCode.isEmpty || employeeCompany.isEmpty || employeeProfession.isEmpty {
            viewModel.toast = Toast.alert(title: "alert".localizedString(), subTitle: "all_mandatory_fields_required".localizedString())
            return
        }
        let newEmployee = Employee(id: -1, employeeCode: employeeCode, employeeName: employeeName, companyName: employeeCompany, profession: employeeProfession)
        manualEmployees.append(newEmployee)
        resetEmployeeFields()
        viewModel.toast = Toast.alert(title: "success".localizedString(), subTitle: "employee_added".localizedString(), isSuccess: true)
        
    }
    
    func resetEmployeeFields() {
        employeeCode = ""
        employeeName = ""
        employeeCompany = ""
        employeeProfession = ""
    }

    
    func createIncident() {
        viewModel.publish(id: -1, date: incidentDate, time: incidentTime, incidentLocation: incidentLocation, incidentType: selectedIncidentType, injuredEmployees: injuredEmployees, description: description, corrections: corrections, facilities: groupData, images: imagesDatas,isInjuredTrue: isInjuredTrue, isInjuredFalse: isInjuredFalse, reportedBy: reportedBy) { completed in
            showSuccessAlert.toggle()
            onSuccess?()
        }
    }
    
    func generatePdf(incident: Incident) {
        viewModel.generatePdf(incident: incident) { completed in
            viewModel.savePdfWithProgress(urlString: viewModel.pdfUrl, fileName: "ALNASR - Incidents(\(viewModel.incident?.id ?? -1)).pdf")
        }
    }
    
    func saveAsDraft() {
        viewModel.saveAsDraft(id: -1, date: incidentDate, time: incidentTime, incidentLocation: incidentLocation, incidentType: selectedIncidentType, injuredEmployees: injuredEmployees, description: description, corrections: corrections, facilities: groupData, images: imagesDatas, reportedBy: reportedBy){ completed in
            if completed {
                successAlertforDraft.toggle()
            }
        }
    }
    
    func setIndicent(incident: Incident) {
        withAnimation {
            self.isProjectOption = (incident.facilities != nil)
            self.isGroupView = (incident.facilities != nil)
            self.isGroupActive = (incident.facilities != nil)
            self.groupData = incident.facilities
            self.bulkEmployees = incident.injuredEmployees ?? []
            self.manualEmployees = []
            self.isInjuredTrue = !(incident.injuredEmployees?.isEmpty ?? true)
            self.isInjuredFalse = incident.injuredEmployees?.isEmpty ?? false
            self.incidentDate = incident.incidentDate.repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    self.incidentTime = incident.incidentTime.repoDate(inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local)
                }
            }
            self.selectedIncidentType = incident.incidentType
            self.incidentLocation = incident.incidentLocation ?? ""
            self.description = incident.description ?? ""
            self.corrections = incident.corrections ?? ""
            self.imagesDatas = incident.images ?? []
            self.imageCount = incident.images?.count ?? 0
            self.reportedBy = incident.reportedBy
        }
    }
    
    func savePdf(urlString:String) {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let pdfNameFromUrl = "ALNASR - Incidents(\(viewModel.incident?.id ?? -1)).pdf"
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

extension CreateIncidentView {
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

