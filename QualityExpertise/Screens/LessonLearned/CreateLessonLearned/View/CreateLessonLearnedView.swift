//
//  CreateLessonLearnedView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 18/07/25.
//

import SwiftUI

struct CreateLessonLearnedView: View {
    internal init(lesson: LessonLearned?, draftLesson: LessonLearned? = nil, isViewOnly: Bool = false, onSuccess: (() -> ())? = nil) {
        _viewModel = StateObject(wrappedValue: CreateLessonLearnedViewModel(lesson: lesson, draftLesson: draftLesson))
        self.isViewOnly = isViewOnly
        self.onSuccess = onSuccess
    }
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode

    @State private var isProjectOption: Bool = false
    @State private var isGroupView: Bool = false
    @State private var isGroupActive: Bool = false
    @State private var groupData: GroupData? = nil 
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reportedBy: String = ""
    
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
    
    @StateObject var viewModel: CreateLessonLearnedViewModel
    
    let isViewOnly: Bool
    let onSuccess: (() -> ())?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                contentView
                    .onAppear {
                        if !isViewOnly {
                            self.reportedBy = UserManager.getLoginedUser()?.name ?? ""
                        }
                        viewModel.fetchViolationDetails() { lesson in
                            if let lesson {
                                DispatchQueue.safeAsyncMain {
                                    setViolation(lesson: lesson)
                                }
                            }
                        }
                    }
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
                
            }
            .navigationBarTitle(isViewOnly ? "" : "lesson_learned".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    if isViewOnly {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } else {
                        showBackButtonalert.toggle()
                    }
                })
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isViewOnly, let lesson = viewModel.lesson {
                        HStack(spacing: 5){
                            if viewModel.isDownloading {
                                CircularDownloadProgressView(progress: viewModel.downloadProgress)
                                    .padding()
                            } else {
                                Button {
                                    generatePdf(lesson: lesson)
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
        .pickerViewerOverlay(viewerShown: $showSuccessAlert, title: "lessons_learned_created".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("lessons_learned_created_success".localizedString())
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
            if !isPDFSelected, let lesson = viewModel.lesson {
                let message = viewModel.getShareMessage(lesson: lesson)
                showActivityViewController(activities: [message])
            } else {
                if let lesson = viewModel.lesson {
                    viewModel.generatePdf(lesson: lesson) { completed in
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
                    Text("lessons_learned_created_as_draft")
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
                    Text("lessons_learned_created_as_draft_without_grp_specs".localizedString())
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
            Text("lesson_learned".localizedString())
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
                
                ThemeTextEditorView(text: $title, title: "title".localizedString(), isMandatoryField: true)
                
                decriptionView
                
            }
            .disabled(isViewOnly)
            
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
                ButtonWithLoader(action: {createLessonLearned()}, title: "publish".localizedString(), width: screenWidth - ( 25 * 2 ), height: 52, isLoading: .constant(false))
                
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
            CreateLessonLearnedImageView(
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
                }, isViewOnly: isViewOnly, viewModel: CreateLessonLearnedImageViewModel(item: imagesDatas[index], index: index),
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
            
            if !isViewOnly {
                Text("provide_relevent_details".localizedString())
                    .font(.lightItalic(8))
                    .foregroundColor(Color.Blue.GREY)
                    .leftAlign()
            }
        }
    }
    
    func createLessonLearned() {
        viewModel.publish(title: title, description: description, groupData: groupData, image: imagesDatas, reportedBy: reportedBy) { completed in
            showSuccessAlert.toggle()
            onSuccess?()
            
        }
    }
    
    func generatePdf(lesson: LessonLearned) {
        viewModel.generatePdf(lesson: lesson) { completed in
            viewModel.savePdfWithProgress(urlString: viewModel.pdfUrl, fileName: "QualityExpertise - Lesson Learned(\(viewModel.lesson?.id ?? -1)).pdf")
        }
    }
    
    func saveAsDraft() {
        viewModel.saveAsDraft(title: title, description: description, groupData: groupData, image: imagesDatas, reportedBy: reportedBy){ completed in
            if completed {
                successAlertforDraft.toggle()
            }
        }
    }
    
    func setViolation(lesson: LessonLearned) {
        withAnimation {
            self.isProjectOption = (lesson.facilities != nil)
            self.isGroupView = (lesson.facilities != nil)
            self.isGroupActive = (lesson.facilities != nil)
            self.groupData = lesson.facilities
            self.title = lesson.title
            self.description = lesson.description ?? ""
            self.imagesDatas = lesson.images ?? []
            self.imageCount = lesson.images?.count ?? 0
            self.reportedBy = lesson.reportedBy
        }
    }
    
    func savePdf(urlString:String) {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let pdfNameFromUrl = "QualityExpertise - Lesson Learned(\(viewModel.lesson?.id ?? -1)).pdf"
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

extension CreateLessonLearnedView {
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

