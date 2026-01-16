//
//  CreatePreTaskView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 24/10/25.
//


import SwiftUI

struct CreatePreTaskView: View {
    internal init(preTask: PreTask?, preTaskId: Int? = nil, notificationId: Int? = nil, draftPreTask: PreTask? = nil, isViewOnly: Bool = false, onSuccess: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CreatePreTaskViewModel(preTask: preTask, draftPreTask: draftPreTask, preTaskId: preTaskId, notificationId: notificationId))
        self.isViewOnly = isViewOnly
        self.onSuccess = onSuccess
    }
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode

    @State private var isProjectOption: Bool = false
    @State private var isGroupView: Bool = false
    @State private var isGroupActive: Bool = false
    @State private var groupData: GroupData? = nil
    @State private var isUserActive: Bool = false
    @State var userData: UserData?
    @State private var otherQuestions: [PreTaskQuestion] = [PreTaskQuestion(id: 1, title: "")]
    
    @State private var date: Date?
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var notes: String = ""
    
    @State private var msraReference: String = ""
    @State private var permitReference: String = ""
    @State private var taskTitle: String = ""
    
    @State private var reportedBy: String = ""
    @State private var employeeName: String = ""
    @State private var employeeCode: String = ""
    @State private var employeeCompany: String = ""
    @State private var employeeProfession: String = ""
    
    @State private var isUserActiveForNotification: Bool = false
    @State var userDatas: [UserData]?
    
    @State private var manualEmployees: [Employee] = []
    @State private var bulkEmployees: [Employee] = []
    @State private var attendentedEmployees: [Employee] = []

    
    private var hasUpdatedValue: Bool {
        viewModel.hasUpdates
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
    @State private var showTimePickerForStartTime: Bool = false
    @State private var showTimePickerForEndTime: Bool = false
    

    
    @StateObject var viewModel: CreatePreTaskViewModel
    
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
                            viewModel.fetchEmployees()
                            viewModel.getTopics()
                        }
                        viewModel.fetchPreTaskDetails { preTask in
                            if let preTask {
                                setPreTask(preTask: preTask)
                            }
                        }
                    }
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }

                
            }
            .navigationBarTitle(isViewOnly ? "" : "pre_task".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    if isViewOnly {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } else {
                        showBackButtonalert.toggle()
                    }
                })
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isViewOnly, let preTask = viewModel.preTask {
                        HStack(spacing: 5){
                            if viewModel.isDownloading {
                                HStack(spacing: 6) {
                                    CircularDownloadProgressView(progress: viewModel.downloadProgress)
                                        .foregroundColor(Color.blue)
                                        .padding()
                                }
                                .padding(.vertical, 8)
                            } else {
                                
                                Button {
                                    generatePdf(preTask: preTask)
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
        .onChange(of: date) { newValue in
            startTime = nil
            endTime = nil
        }
        .onChange(of: startTime) { newValue in
            endTime = nil
        }
        .onChange(of: groupData) { _ in
            isUserActiveForNotification = false
            userDatas = []
        }
        
        .overlay(
            Group {
                if viewModel.pdfLoading {
                    PDFLoadingOverlay()
                }
            }
        )
        .overlay(
            DatePickerView(selectedDate: $date, showDatePicker: $showDatePicker)
                .ignoresSafeArea()
        )
        .overlay(
            TimePickerView(selectedTime: $startTime, showTimePicker: $showTimePickerForStartTime, selectedDate: date)
                .ignoresSafeArea()
        )
        .overlay(
            TimePickerView(selectedTime: $endTime, showTimePicker: $showTimePickerForEndTime, selectedDate: date)
                .ignoresSafeArea()
        )
        .pickerViewerOverlay(viewerShown: $showSuccessAlert, title: "pre_task_created".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("pre_task_created_success".localizedString())
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
            if !isPDFSelected, let preTask = viewModel.preTask {
                let message = viewModel.getShareMessage()
                showActivityViewController(activities: [message])
            } else {
                if let preTask = viewModel.preTask {
                    viewModel.generatePdf(preTask: preTask) { completed in
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
                    Text("pre_task_draft_success".localizedString())
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
        .pickerViewerOverlay(viewerShown: $groupSpecifiedAlert, title: "Draft Saved".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("pre_task_draft_success".localizedString())
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
            Text("pre_task".localizedString())
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
                                    userDatas = nil
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
                
                ThemeDatePickerView(date: $date, title: "date".localizedString(), placeholder: "enter_date".localizedString(), showDatePicker: $showDatePicker)
                    .disabled(isViewOnly)
                
                ThemeTextEditorView(text: $msraReference, title: "msra_reference".localizedString(), isMandatoryField: false)
                    .disabled(isViewOnly)
                
                HStack {
                    ThemeDatePickerView(date: $startTime, title: "start_time".localizedString(), placeholder: Constants.DateFormat.TIME_PLACEHOLDER, isTimePicker: true, showDatePicker: $showTimePickerForStartTime)
                        .frame(width: screenWidth/3)
                        .leftAlign()
                        .disabled(isViewOnly)
                    
                    Spacer()
                    
                    ThemeDatePickerView(date: $endTime, title: "end_time".localizedString(), placeholder: Constants.DateFormat.TIME_PLACEHOLDER, isTimePicker: true, showDatePicker: $showTimePickerForEndTime)
                        .frame(width: screenWidth/3)
                        .disabled(isViewOnly)
                    
                }
        
                
                ThemeTextEditorView(text: $permitReference, title: "permit_reference".localizedString(), isMandatoryField: false)
                    .disabled(isViewOnly)
                
                ThemeTextEditorView(text: $taskTitle, title: "task_title".localizedString(), isMandatoryField: true)
                    .disabled(isViewOnly)
                
                if groupData != nil && !isViewOnly {
                    sendNotificationView
                }
                
                discussionPointView
                    .padding(.vertical, 15)
                
                notesView
                    .padding(.bottom, 15)
                
                
                AddInjuredPersonView(
                    employeeCode: $employeeCode,
                    employeeName: $employeeName,
                    employeeCompany: $employeeCompany,
                    employeeProfession: $employeeProfession,
                    attendentedEmployees: $attendentedEmployees,
                    manualEmployees: $manualEmployees,
                    bulkEmployees: $bulkEmployees,
                    isViewOnly: isViewOnly,
                    viewModel: viewModel,
                    groupData: $groupData
                )
                .localize()
                
            }
            
            
            LeftAlignedHStack(
                Text("attendance_evidence".localizedString())
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
            
            if hasUpdatedValue {
                Text("topic_of_discussion_question_changed".localizedString())
            .font(.lightItalic(10))
            .foregroundColor(Color.Red.LIGHT)
            .multilineTextAlignment(.center)
            }
            
            if !isViewOnly {
                ButtonWithLoader(action:createIncident, title: "publish".localizedString(), width: screenWidth - ( 25 * 2 ), height: 52, isLoading: .constant(false))
                    .opacity(hasUpdatedValue ? 0.5 : 1)
                    .disabled(hasUpdatedValue)
                
                Button {
                    saveAsDraft()
                } label: {
                    Text("save_as_draft".localizedString())
                        .foregroundColor(Color.Orange.PINK)
                        .font(.regular(15))
                }
                .opacity(hasUpdatedValue ? 0.5 : 1)
                .disabled(hasUpdatedValue)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var notesView: some View {
        VStack(spacing: 10) {
            Text("step_by_step".localizedString().uppercased())
                .foregroundColor(Color.Blue.GREY)
                .font(.regular(12))
                .leftAlign()
            
            VStack(spacing: 10) {
                Text("step_by_step_description".localizedString())
                    .padding(10)
                    .font(.lightItalic(8))
                    .foregroundColor(Color.Blue.GREY)
                
                ThemeTextEditorView(text: $notes, title: "", disabled: isViewOnly, keyboardType: nil, isMandatoryField: false, limit: nil, placeholderColor: nil, isTitleCapital: false, isDividerShown: false, isPlaceHolderShown: false)
                    .padding(10)
                    .background(Color.white)
                    .frame(minHeight: 48) // restrict height for one line
                    .cornerRadius(5)
                    .disabled(isViewOnly)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
            .contentShape(Rectangle())
        }
    }



    
    private var addinjuredPersonView: some View {
        VStack(spacing: 10) {
            
            Text("attendes".localizedString())
                .foregroundColor(Color.Blue.THEME)
                .font(.extraBold(14))
                .leftAlign()
                .padding(.bottom, 10)

            
            if !attendentedEmployees.isEmpty {
                employeeDeatilesView
            }
            
            if !isViewOnly {
                Group {
                    ThemeTextEditorView(
                        text: $employeeCode,
                        title: "employee_code".localizedString(),
                        isMandatoryField: false
                    )
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
                        title: "employee_name".localizedString(),
                        isMandatoryField: false
                    )
                    ThemeTextEditorView(
                        text: $employeeCompany,
                        title: "company_name".localizedString().uppercased(),
                        isMandatoryField: false
                    )
                    ThemeTextEditorView(
                        text: $employeeProfession,
                        title: "profession".localizedString().uppercased(),
                        isMandatoryField: false
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
    
    private var discussionPointView: some View {
        VStack(spacing: 5) {
            HStack(spacing: 10) {
                Spacer()
                
                Text("topics_of_discussion".localizedString())
                    .foregroundColor(Color.Blue.THEME)
                    .font(.extraBold(18))
                    .padding(.bottom, 15)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                if viewModel.topics.isEmpty {
                    if let error = viewModel.error {
                        ErrorRetryView(
                            retry: {
                                if isViewOnly || (viewModel.draftPreTask != nil) {
                                    viewModel.fetchPreTaskDetails { preTask in
                                        if let preTask {
                                            setPreTask(preTask: preTask)
                                        }
                                    }
                                } else {
                                    viewModel.getTopics()
                                }
                            },
                            title: "error".localizedString(),
                            message: viewModel.toast.subTitle ?? error.localizedDescription,
                            isDarkMode: false,
                            isError: true
                        )
                        .padding(.bottom, 10)
                    } else {
                        ErrorRetryView(
                            retry: {
                                if isViewOnly || (viewModel.draftPreTask != nil) {
                                    viewModel.fetchPreTaskDetails { preTask in
                                        if let preTask {
                                            setPreTask(preTask: preTask)
                                        }
                                    }
                                } else {
                                    viewModel.getTopics()
                                }
                            },
                            title: "no_questions_found".localizedString(),
                            message: "no_questions".localizedString(),
                            isDarkMode: false,
                            isError: false
                        )
                        .padding(.bottom, 10)
                    }
                } else {
                    ForEach($viewModel.topics) { $topic in
                        TopicView(topic: $topic, viewModel: viewModel)
                            .padding(.bottom, 10)
                            .disabled(isViewOnly)
                    }
                }
                
                if !otherQuestions.isEmpty {
                    OtherQuestionView(
                        otherQuestions: $otherQuestions,
                        viewModel: viewModel,
                        isViewOnly: isViewOnly
                    )
                    .disabled(isViewOnly)
                }
            }
        }
    }
    
    private var sendNotificationView: some View {
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


    
    
    private var imageView: some View {
        ForEach(imagesDatas.indices, id: \.self) { index in
            CreatePreTaskImageView(
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
                }, isViewOnly: isViewOnly, viewModel: CreatePreTaskImageViewModel(item: imagesDatas[index], index: index),
                showImage: $showImage, imageUrlData: $imageData)
        }
        .id(imageListId)
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
                    ForEach(attendentedEmployees.indices, id: \.self) { index in
                        let emp = attendentedEmployees[index]
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
                                    bulkEmployees.removeAll {$0.id == emp.id}
                                    manualEmployees.removeAll {$0.employeeCode == emp.employeeCode}
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
        viewModel.publish(date: date, startTime: startTime, endTime: endTime, taskTitle: taskTitle, msraReference: msraReference, permitReference: permitReference, notes: notes, otherTopic: otherQuestions, attendees: attendentedEmployees, facilities: groupData, images: imagesDatas, reportedBy: reportedBy, sendNotificationTo: userDatas) { completed in
            if completed {
                showSuccessAlert.toggle()
                onSuccess?()
            }
        }
    }
    
    func generatePdf(preTask: PreTask) {
        viewModel.generatePdf(preTask: preTask) { completed in
            viewModel.savePdfWithProgress(urlString: viewModel.pdfUrl, fileName: "\("QualityExpertise - Pre Task Briefing(\(preTask.id))").pdf")
        }
    }
    
    func saveAsDraft() {
        viewModel.saveAsDraft(date: date, startTime: startTime, endTime: endTime, taskTitle: taskTitle, msraReference: msraReference, permitReference: permitReference, notes: notes, otherTopic: otherQuestions, attendees: attendentedEmployees, facilities: groupData, images: imagesDatas, reportedBy: reportedBy, sendNotificationTo: userDatas) { completed in
            if completed {
                successAlertforDraft.toggle()
            }
        }
    }
    
    func setPreTask(preTask: PreTask) {
        withAnimation {
            DispatchQueue.main.async {
                self.date = preTask.date.repoDate(inputFormat: Constants.DateFormat.REPO_DATE, local: LocalizationService.shared.language.local)
            }
            self.isProjectOption = (preTask.facilities != nil)
            self.isGroupView = (preTask.facilities != nil)
            self.isGroupActive = (preTask.facilities != nil)
            self.isUserActiveForNotification = !(preTask.sendNotificationTo?.isEmpty ?? true)
            self.userDatas = preTask.sendNotificationTo
            self.groupData = preTask.facilities
            self.bulkEmployees = preTask.attendees ?? []
            self.manualEmployees = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.startTime = preTask.startTime?.repoDate(inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.endTime = preTask.endTime?.repoDate(inputFormat: Constants.DateFormat.REPO_TIME, local: LocalizationService.shared.language.local)
            }
            self.imagesDatas = preTask.images ?? []
            self.imageCount = preTask.images?.count ?? 0
            self.reportedBy = preTask.reportedBy
            self.msraReference = preTask.msraReference ?? ""
            self.permitReference = preTask.permitReference ?? ""
            self.notes = preTask.notes ?? ""
            self.taskTitle = preTask.taskTitle
            
            self.otherQuestions = preTask.otherTopic ?? []
            
        }
    }
    
    func savePdf(urlString: String) {
        guard let url = URL(string: urlString) else {
            viewModel.toast = Toast.alert(subTitle: "Invalid URL")
            return
        }

        // Run download asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    viewModel.toast = Toast.alert(subTitle: "pdf_save_failed".localizedString())
                }
                print("PDF download error:", error)
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    viewModel.toast = Toast.alert(subTitle: "pdf_save_failed".localizedString())
                }
                return
            }
            
            let resourceDocPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            let pdfNameFromUrl = "QualityExpertise - Pre Task Breifing(\(viewModel.preTask?.id ?? -1)).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            
            do {
                try data.write(to: actualPath, options: .atomic)
                DispatchQueue.main.async {
                    viewModel.toast = "pdf_saved_success".localizedString().successToast
                }
            } catch {
                DispatchQueue.main.async {
                    viewModel.toast = Toast.alert(subTitle: "pdf_save_failed".localizedString())
                }
            }
            
        }.resume()
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

extension CreatePreTaskView {
    struct ImageView: View {
        var count: Int
        var imageDescription: ImageData
        @Binding var imageData: String?
        @Binding var showImages: Bool
        
        var body: some View {
            VStack {
                VStack {
                    LeftAlignedHStack(
                        Text("image".localizedString() + " \(count)")
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

extension CreatePreTaskView {
    
    // MARK: - Topic Section
    struct TopicView: View {
        @Binding var topic: PreTaskTopic
        @ObservedObject var viewModel: CreatePreTaskViewModel
        
        var body: some View {
            if !topic.questions.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text(topic.title.uppercased())
                        .font(.bold(14))
                        .foregroundColor(Color.Black.DARK)
                        .leftAlign()
                    
                    // Questions
                    ForEach($topic.questions) { $question in
                        QuestionView(question: $question, viewModel: viewModel)
                    }
                }
                .padding(.vertical, 10)
            }
            
        }
    }
    
    // MARK: - Individual Question View
    struct QuestionView: View {
        @Binding var question: PreTaskAPI.Question
        @ObservedObject var viewModel: CreatePreTaskViewModel
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                // Question Title
                HStack(spacing: 2) {
                    Text(question.title)
                        .font(.regular(13))
                        .foregroundColor(Color.Grey.SLATE)
                    
                    Text("*")
                        .foregroundColor(Color.Red.CORAL)
                        .font(.regular(12))
                }
                
                // Answer Options + Optional Image
                HStack(alignment: .center, spacing: 16) {
                    ForEach([PreTaskAnswer.yes, PreTaskAnswer.no, PreTaskAnswer.notApplicable], id: \.self) { answer in
                        AnswerOptionView(
                            label: answer.title,
                            isSelected: question.selectedAnswer == answer
                        )
                        .onTapGesture {
                            question.selectedAnswer = answer
                            viewModel.updateQuestion(question)
                        }
                    }

                    Spacer()

                    if let imageURL = question.imageUrl?.url {
                        WebUrlImage(url: imageURL)
                            .frame(width: 40, height: 40)
                    }
                }

                Divider()
            }
        }
    }
    
    // MARK: - Answer Option View
    struct AnswerOptionView: View {
        var label: String
        var isSelected: Bool

        var body: some View {
            HStack(spacing: 6) {
                Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                Text(label)
                    .font(.regular(12))
                    .foregroundColor(Color.Blue.GREY)
            }
        }
    }

    // MARK: - Other Questions Section
    struct OtherQuestionView: View {
        @Binding var otherQuestions: [PreTaskQuestion]
        @ObservedObject var viewModel: CreatePreTaskViewModel
        var isViewOnly: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Section Title
                Text("others".localizedString())
                    .font(.bold(14))
                    .foregroundColor(Color.Black.DARK)
                
                // Dynamic Question List
                ForEach($otherQuestions) { $question in
                    VStack(alignment: .leading, spacing: 20) {
                        // Text field for custom question
                        ThemeTextEditorView(
                            text: $question.title,
                            title: "",
                            placeholder: "enter_question".localizedString() + " \(question.id)",
                            isMandatoryField: false,
                            isPlaceHolderShown: true
                        )

                        // Answer Options
                        HStack(alignment: .center, spacing: 16) {
                            ForEach([PreTaskAnswer.yes, PreTaskAnswer.no, PreTaskAnswer.notApplicable], id: \.self) { answer in
                                AnswerOptionView(
                                    label: answer.title,
                                    isSelected: question.selectedAnswer == answer
                                )
                                .onTapGesture {
                                    if question.title == "" {
                                        viewModel.toast = Toast.alert(title: "alert".localizedString(), subTitle: "invalid_question".localizedString())
                                    } else {
                                        question.selectedAnswer = answer
                                    }
                                }
                                .onChange(of: question.title) { newValue in
                                    if newValue.isEmpty {
                                        question.selectedAnswer = nil
                                    }
                                }
                            }
                        }

                        Divider()
                    }
                }

                if !isViewOnly {
                    HStack {

                        Button(action: addNewQuestion) {
                            HStack(spacing: 4) {
                                Image(IC.ACTIONS.PLUS)
                                    .foregroundColor(Color.Green.DARK_GREEN)
                                
                                Text("add_new".localizedString())
                                    .font(.regular(12))
                                    .foregroundColor(Color.Blue.THEME)
                            }
                            .padding(.top, 15)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 10)
        }
        
        private func addNewQuestion() {
            let newId = (otherQuestions.last?.id ?? 0) + 1
            otherQuestions.append(PreTaskQuestion(id: newId, title: "", selectedAnswer: nil))
        }
    }
}


