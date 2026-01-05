//
//  LessonLearnedListView.swift
//  ALNASR
//
//  Created by Amarjith B on 18/07/25.
//


import SwiftUI


struct LessonLearnedListView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var searchText = Constants.EMPTY_STRING
    @State private var closeButtonActive = false
    @State private var isListSorted: Bool = false
    @State var filterCount: Int = 0
    @State private var isListChanged = false
    @State var isActive: Bool = false
    @State var startDate: Date? = nil
    @State var endDate: Date? = nil
    @State var reportedByIds: [Int] = []
    @State var projectsIds: [Int] = []
    @State private var noProjectSpecified: Bool = false
    @StateObject private var viewModel = LessonLearnedListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        HStack(spacing: 15) {
                            Image(IC.ACTIONS.PLUS)
                                .foregroundColor(Color.Green.DARK_GREEN)
                            
                            Text("add_new".localizedString())
                                .font(.light(12))
                                .foregroundColor(Color.Blue.THEME)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 27)
                        .padding(.top, 16)
                        .onTapGesture {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                CreateLessonLearnedView(
                                    lesson: nil,
                                    draftLesson: nil,
                                    onSuccess: {
                                        viewModel.resetPagination()
                                        fetchList(isInital: true)
                                    }
                                )
                                .localize()
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(IC.VIOLATIONS.DRAFT)
                                .foregroundColor(Color.Green.DARK_GREEN)
                            
                            Text("drafts".localizedString())
                                .font(.light(12))
                                .foregroundColor(Color.Blue.THEME)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 27)
                        .padding(.top, 16)
                        .onTapGesture {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                DraftLessonLearnedListContentView(onNewViolationAdded: {
                                    viewModel.resetPagination()
                                    fetchList(isInital: true)
                                })
                                .localize()
                            }
                        }
                    }
                    
                    // Search field
                    SearchFieldInputView(
                        onEditingChanged: {
                            viewModel.resetPagination()
                            fetchList(isInital: true)
                        },
                        onDone: {
                            closeKeyboard()
                            viewModel.resetPagination()
                            fetchList(isInital: true)
                        },
                        text: $searchText,
                        placeholder: "search_lesson_learned".localizedString(),
                        closeButtonActive: closeButtonActive,
                        foregroundColor: Color.Indigo.DARK,
                        background: Color.white,
                        placeholderColor: Color.Indigo.DARK,
                        onCloseClicked: {
                            viewModel.resetPagination()
                            fetchList(isInital: true)
                        }
                    )
                    .onChange(of: isActive) { (value) in
                        viewModel.resetPagination()
                        fetchList(isInital: true)
                        setFilterCount()
                    }
                    .onChange(of: isListSorted) { value in
                        viewModel.sortLessons(searchText: searchText, sortType: isListSorted ? .ascending : .descending, selectedProjectIds: projectsIds, openDate: startDate, endDate: endDate, selectedReportedByPersonIds: reportedByIds, noProjectSpecified: noProjectSpecified)
                    }
                    .onChange(of: searchText) { value in
                        closeButtonActive = !value.isEmpty
                        viewModel.resetPagination()
                        fetchList(isInital: true)
                    }
                    .onChange(of: isListChanged) { value in
                        if value {
                            fetchList()
                            isListChanged = false
                        }
                    }
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                    .padding(.horizontal, 27)
                    .padding(.top, 10)
                    
                    listView
                }
                
                // Export button
                if viewModel.searchLessons.count > 0 {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                exportToExcel()
                            } label: {
                                Text("export_to_excel".localizedString())
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.medium(16))
                                    .frame(maxWidth: 150, minHeight: 45)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22.5)
                                            .stroke(Color.Blue.THEME, lineWidth: 0.5)
                                    )
                                    .padding(.bottom, 35)
                            }
                            .background(Color.white)
                            
                            Spacer()
                        }
                        .frame(height: 80)
                        .background(Color.white)
                    }
                    .ignoresSafeArea()
                }
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .navigationBarTitle("lesson_learned".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button {
                            isListSorted.toggle()
                        } label: {
                            Image(isListSorted ? IC.ACTIONS.SORT_REVERSE : IC.ACTIONS.SORT)
                        }
                        
                            Button {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    FilterSectionContentView(noProjectSpecified: $noProjectSpecified, startDate: $startDate, endDate: $endDate, isActive: $isActive, selectedProjectIds: $projectsIds, selectedResponsibleIds: $reportedByIds, selectedIncidentIds: .constant([]), title: "lessons".localizedString())
                                        .localize()
                                }
                            } label: {
                                ZStack {
                                    Image(IC.ACTIONS.FILTER)
                                    
                                    if filterCount > 0 {
                                        Text(filterCount.string)
                                            .padding(6)
                                            .background(Color.Blue.THEME)
                                            .clipShape(Circle())
                                            .foregroundColor(Color.white)
                                            .font(.regular(12))
                                            .offset(x: -7, y: -12)

                                    }
                                }
                            }
                        
                    }
                }
            }
            .onAppear {
                fetchList()
                
            }
            .listenToAppNotificationClicks()
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden()
    }
    
    var listView: some View {
        VStack {
            // Content area
            if viewModel.noDataFound {
                "no_lesson_learned_found".localizedString()
                    .viewRetry {
                        viewModel.resetPagination()
                        fetchList(isInital: true)
                    }
                    .verticalCenter()
                Spacer()
                
            } else if let error = viewModel.error {
                error.viewRetry(isError: true) {
                    fetchList()
                }
                .verticalCenter()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchLessons.indices, id: \.self) { index in
                            let lesson = viewModel.searchLessons[index]
                            LessonLearnedListRowView(lesson: lesson)
                                .onTapGesture {
                                    viewControllerHolder?.present(style: .overCurrentContext) {
                                        CreateLessonLearnedView(
                                            lesson: lesson,
                                            draftLesson: nil,
                                            isViewOnly: true
                                        )
                                        .localize()
                                    }
                                }
                                .onAppear {
                                    // Trigger pagination when last item appears
                                    if index == viewModel.searchLessons.count - 1 {
                                        fetchList()
                                    }
                                }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 27)
                    .padding(.bottom, 65) // Space for export button
                }
                .padding(.top, 10)
            }
        }
    }
    
    private func fetchList(isInital: Bool = false) {
        viewModel.fetchLessonsList(searchText: searchText, sortType: isListSorted ? .ascending : .descending, isInital: isInital, selectedProjectIds: projectsIds, openDate: startDate, endDate: endDate, selectedReportedByPersonIds: reportedByIds, noProjectSpecified: noProjectSpecified)
    }
    
    private func exportToExcel() {
        viewModel.exportToExcel(searchKey: searchText ,sortType: isListSorted ? .ascending : .descending, selectedProjectsIds: projectsIds, openDate: startDate, endDate: endDate, reportedByPersonsIds: reportedByIds, noProjectSpecified: noProjectSpecified) {
            saveExcel(urlString: viewModel.excelUrl)
        }
    }
    
    func setFilterCount() {
        filterCount = 0
        if !projectsIds.isEmpty || noProjectSpecified {
            filterCount += 1
        }
        
        if !reportedByIds.isEmpty {
            filterCount += 1
        }
        
        if startDate != nil || endDate != nil {
            filterCount += 1
        }
    }
    
    private func saveExcel(urlString: String) {
        guard let url = URL(string: urlString),
              let pdfData = try? Data(contentsOf: url) else {
            viewModel.toast = Toast.alert(subTitle: "excel_download_failed".localizedString())
            return
        }
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "ALNASR - Lesson Learned Log \(Date().formattedDateString(format: "dd.MM.yyyy")).csv"
        let filePath = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: filePath, options: .atomic)
            viewModel.toast = "excel_successfully_saved".localizedString().successToast
        } catch {
            viewModel.toast = Toast.alert(subTitle: "excel_could_not_be_saved".localizedString())
        }
    }
}

// MARK: - Preview

struct LessonLearnedListView_Previews: PreviewProvider {
    static var previews: some View {
        LessonLearnedListView()
    }
}
