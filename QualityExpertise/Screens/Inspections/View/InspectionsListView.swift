//
//  InspectionsListView.swift
//  ALNASR
//
//  Created by Amarjith B on 03/06/25.
//

import SwiftUI


struct InspectionsListView: View {
    
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
    
    
    @StateObject private var viewModel = InspectionsListViewModel()
    private let updateList = NotificationCenter.default.publisher(for: .UPDATE_INSPECTIONS_LIST)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        HStack(spacing: 15) {
                            Image(IC.ACTIONS.PLUS)
                                .foregroundColor(Color.Green.DARK_GREEN)
                            
                            Text("add_new")
                                .font(.light(12))
                                .foregroundColor(Color.Blue.THEME)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 27)
                        .padding(.top, 16)
                        .onTapGesture {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                AuditsInspectionsView(isListChanged: $isListChanged)
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
                                DraftInspectionsListContentView(onNewInspectionAdded: {
                                    viewModel.resetPagination()
                                    fetchInspectionsList(isInital: true)
                                })
                                .localize()
                            }
                        }
                    }
                    // Search field
                    SearchFieldInputView(
                        onEditingChanged: {
                            viewModel.resetPagination()
                            fetchInspectionsList(isInital: true)
                        },
                        onDone: {
                            closeKeyboard()
                            viewModel.resetPagination()
                            fetchInspectionsList(isInital: true)
                        },
                        text: $searchText,
                        placeholder: "search_inspections".localizedString(),
                        closeButtonActive: closeButtonActive,
                        foregroundColor: Color.Indigo.DARK,
                        background: Color.white,
                        placeholderColor: Color.Indigo.DARK,
                        onCloseClicked: {
                            viewModel.resetPagination()
                            fetchInspectionsList(isInital: true)
                        }
                    )
                    .onChange(of: isListSorted, perform: { (value) in
                        viewModel.sortInspections(
                            searchText: searchText,
                            sortType: isListSorted ? .ascending : .descending,
                            selectedProjectsIds: projectsIds,
                            openDate: startDate,
                            endDate: endDate,
                            reportedByPersonsIds: reportedByIds,
                            noProjectSpecified: noProjectSpecified)
                    })
                    .onChange(of: searchText) { _ in
                        viewModel.resetPagination()
                        fetchInspectionsList(isInital: true)
                    }
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                    .onChange(of: searchText) { value in
                        closeButtonActive = !value.isEmpty
                    }
                    .onChange(of: isActive) { (value) in
                        viewModel.resetPagination()
                        fetchInspectionsList(isInital: true)
                        setFilterCount()
                    }
                    .onChange(of: isListChanged) { value in
                        if value {
                            viewModel.resetPagination()
                            fetchInspectionsList(isInital: true)
                            isListChanged = false
                        }
                    }
                    .padding(.horizontal, 27)
                    .padding(.top, 10)
                    .onReceive(updateList, perform: { (output) in
                        viewModel.resetPagination()
                        fetchInspectionsList(isInital: true)
                    })
                    
                    // Content area
                    if viewModel.noDataFound {
                        "no_inspections_found".localizedString()
                            .viewRetry {
                                viewModel.resetPagination()
                                fetchInspectionsList(isInital: true)
                        }
                            .verticalCenter()
                        Spacer()
                        
                    } else if let error = viewModel.error {
                        error.viewRetry(isError: true) {
                            fetchInspectionsList()
                        }
                        .verticalCenter()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.inspections.indices, id: \.self) { index in
                                    let inspection = viewModel.inspections[index]
                                    InspectionListRowView(
                                        inspections: inspection,
                                        viewModel: .init(inspection: inspection)
                                    )
                                    .onTapGesture {
                                        viewControllerHolder?.present(style:.overCurrentContext) {
                                            CreateEquipmentStaticView(
                                                viewModel:.init(
                                                    inspectionID: inspection.id,
                                                    inspection: inspection,
                                                    draftInspection: nil,
                                                    inspectionTypeID: inspection.auditItem.auditItemId),
                                                isListChanged:.constant(false) ,inspectionType: inspection.auditItem, isViewOnly: true)
                                            .localize()
                                        }
                                    }
                                    .onAppear {
                                        if viewModel.inspections.count - 1 == index {
                                            fetchInspectionsList()
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
                
                if viewModel.searchInspections.count > 0 {
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
                
                // Loading indicator
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .onChange(of: isListSorted) { value in
                
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .navigationBarTitle("audits_inspection".localizedString(), displayMode: .inline)
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
                                    FilterSectionContentView(noProjectSpecified: $noProjectSpecified, startDate: $startDate, endDate: $endDate, isActive: $isActive, selectedProjectIds: $projectsIds, selectedResponsibleIds: $reportedByIds, selectedIncidentIds: .constant([]), title: "inspections".localizedString())
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
                setFilterCount()
                fetchInspectionsList()
            }
            .listenToAppNotificationClicks()
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden()
    }
    
    private func fetchInspectionsList(isInital: Bool = false) {
        viewModel.fetchInspectionsList(searchText: searchText, sortType: isListSorted ? .ascending : .descending, isInital: isInital, selectedProjectsIds: projectsIds, openDate: startDate, endDate: endDate, reportedByPersonsIds: reportedByIds, noProjectSpecified: noProjectSpecified)
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
        let fileName = "ALNASR - Inspections Log \(Date().formattedDateString(format: "dd.MM.yyyy")).csv"
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

struct InspectionsListView_Previews: PreviewProvider {
    static var previews: some View {
        InspectionsListView()
    }
}
