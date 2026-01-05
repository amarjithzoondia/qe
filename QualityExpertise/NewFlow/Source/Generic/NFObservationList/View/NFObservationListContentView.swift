//
//  NFObservationListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct NFObservationListContentView: View {
    @StateObject var viewModel = NFObservationListViewModel()
    @StateObject private var userManager = UserManager.shared
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var searchText = Constants.EMPTY_STRING
    @State var closeButtonActive = false
    @State var isOpenObservationSelected = false
    @State var isClosedObservationSelected = false
    @State var selectedGroupsIds: [Int] = []
    @State var selectedObserversIds: [Int] = []
    @State var selectedResponsiblePersonsIds: [Int] = []
    @State var startDate: Date? = nil
    @State var endDate: Date? = nil
    @State var noGroupSpecified = false
    @State var isActive: Bool = false
    @State var filterCount: Int = 0
    @State var isListSorted: Bool = false
    let closeObservationPublisher = NotificationCenter.default.publisher(for: .CLOSE_OBSERVATION)
    let deleteObservationPublisher = NotificationCenter.default.publisher(for: .DELETE_OBSERVATION)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        // Add New
                        HStack(spacing: 10) {
                            Image(IC.ACTIONS.PLUS)
                                .foregroundColor(Color.Green.DARK_GREEN)
                            
                            Text("add_new".localizedString())
                                .font(.light(12))
                                .foregroundColor(Color.Blue.THEME)
                                .lineLimit(1) // ✅ force single line
                        }
                        .onTapGesture {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFCreateObservationContentView(draftObservation: .constant(NFObservationDraftData.empty), onObservationCreate: {
                                    fetchObservationList()
                                })
                                .localize()
                            }
                        }
                        
                        Spacer()
                        
                        // Pending Actions
                        HStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Image(IC.DASHBOARD.TAB.PENDING_ACTIONS_SELECTED)
                                    .resizable()
                                    .frame(width: 19, height: 19)
                                
                            }
                            
                            
                            Text("pending_actions".localizedString())
                                .font(.light(12))
                                .foregroundColor(Color.Blue.THEME)
                                .lineLimit(1) // ✅ force single line
                        }
                        .onTapGesture {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFPendingActionsListContentView()
                                    .localize()
                            }
                        }
                        
                        Spacer()
                        
                        // Drafts
                        HStack(spacing: 4) {
                            Image(IC.VIOLATIONS.DRAFT)
                                .foregroundColor(Color.Green.DARK_GREEN)
                            
                            Text("drafts".localizedString())
                                .font(.light(12))
                                .foregroundColor(Color.Blue.THEME)
                                .lineLimit(1)
                        }
                        .onTapGesture {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFDraftObservationListContentView()
                                    .localize()
                            }
                        }
                    }
                    .padding(.horizontal, 27)
                    .padding(.top, 16)

                    SearchFieldInputView(
                        onEditingChanged: {
                            fetchObservationList()
                        },
                        onDone: {
                            closeKeyboard()
                            fetchObservationList()
                        },
                        text: $searchText,
                        placeholder: "search_observations".localizedString(),
                        closeButtonActive: closeButtonActive,
                        foregroundColor: Color.Indigo.DARK,
                        background: Color.white,
                        placeholderColor: Color.Indigo.DARK,
                        onCloseClicked: {
                            fetchObservationList()
                        }
                    )
                    .onChange(of: searchText) { _ in
                        fetchObservationList()
                    }
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                    .onChange(of: searchText, perform: { value in
                        if searchText == "" {
                            closeButtonActive = false
                        } else {
                            closeButtonActive = true
                        }
                    })
                    .padding(.horizontal, 27)
                    .padding(.top, 10)
                
                    if viewModel.noDataFound {
                        "no_observations_found".localizedString()
                            .viewRetry {
                                fetchObservationList()
                        }
                            .verticalCenter()
                    } else if let error = viewModel.error {
                        error.viewRetry {
                            fetchObservationList()
                        }
                        .verticalCenter()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.searchObservations, id: \.observationId) { (observation) in
                                    if let index = viewModel.searchObservations.firstIndex(of: observation) {
                                        if index.isMultiple(of: 4) && index != 0 {
                                            if viewModel.addTrackingAuthStatus != .notDetermined {
                                                GADBannerViewController()
                                                    .frame(height: 60)
                                            }
                                        }
                                    }
                                    
                                    NFObservationListRowView(viewModel: .init(observation: observation))
                                        .onTapGesture {
                                            viewControllerHolder?.present(style: .overCurrentContext) {
                                                NFObservationDetailContentView(viewModel: .init(observationId: observation.observationId))
                                                    .localize()
                                            }
                                        }
                                }
                            }
                            .padding(.top, 15.5)
                            .padding(.horizontal, 27)
                            .padding(.bottom, (45 + 20))
                        }
                    }
                    
                    Spacer()
                }
                
                if viewModel.searchObservations.count > 0 {
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
                            }
                            .background(Color.white)
                            
                            Spacer()
                        }
                        .frame(height: 60)
                        .background(Color.white)
                    }
                }
                
                if viewModel.isLoading {
                    Color.white.opacity(0.25)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .onChange(of: isListSorted, perform: { (value) in
                viewModel.searchObservations = viewModel.searchObservations.reversed()
            })
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .navigationBarTitle("observations".localizedString(), displayMode: .inline)
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
                        if !(UserManager.getCheckOutUser()?.isGuestUser ?? false) {
                            Button {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    NFFilterObservationListContentView(isOpenObservationSelected: $isOpenObservationSelected, isClosedObservationSelected: $isClosedObservationSelected, selectedGroupsIds: $selectedGroupsIds, selectedObserversIds: $selectedObserversIds, selectedResponsiblePersonsIds: $selectedResponsiblePersonsIds, startDate: $startDate, endDate: $endDate, noGroupSpecified: $noGroupSpecified, isActive: $isActive)
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
            }
            .onAppear(perform: {
                fetchObservationList()
                setFilterCount()
            })
            .onReceive(closeObservationPublisher) { (output) in
                fetchObservationList()
                setFilterCount()
            }
            .onReceive(deleteObservationPublisher) { (output) in
                fetchObservationList()
                setFilterCount()
            }
            .onChange(of: isActive) { (value) in
                fetchObservationList()
                setFilterCount()
            }
            .listenToAppNotificationClicks()
        }
    }
    
    func exportToExcel() {
        viewModel.exportToExcel {
            saveExcel(urlString: viewModel.excelUrl)
        }
    }
    
    func fetchObservationList() {
        viewModel.fetchObservationList(searchText: searchText, isOpenObservationSelected: isOpenObservationSelected, isClosedObservationSelected: isClosedObservationSelected, selectedGroupsIds: selectedGroupsIds, selectedObserversIds: selectedObserversIds, selectedResponsiblePersonsIds: selectedResponsiblePersonsIds, startDate: startDate, endDate: endDate, noGroupSpecified: noGroupSpecified)
    }
    
    func saveExcel(urlString:String) {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let fileName = "ALNASR - Observations Log \(Date().formattedDateString(format: "dd.MM.yyyy")).csv"
        let actualPath = resourceDocPath.appendingPathComponent(fileName)
        do {
            try pdfData?.write(to: actualPath, options: .atomic)
            viewModel.toast = "excel_successfully_saved".localizedString().successToast
        } catch {
            viewModel.toast = Toast.alert(subTitle: "excel_could_not_be_saved".localizedString())
        }
    }
    
    func setFilterCount() {
        filterCount = 0
        if isOpenObservationSelected || isClosedObservationSelected {
            filterCount = filterCount + 1
        }
        
        if selectedGroupsIds.count > 0 || noGroupSpecified {
            filterCount = filterCount + 1
        }
        
        if selectedObserversIds.count > 0 {
            filterCount = filterCount + 1
        }
        
        if selectedResponsiblePersonsIds.count > 0 {
            filterCount = filterCount + 1
        }
        
        if startDate != nil || endDate != nil {
            filterCount = filterCount + 1
        }
    }
}

struct NFObservationListContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFObservationListContentView()
    }
}
