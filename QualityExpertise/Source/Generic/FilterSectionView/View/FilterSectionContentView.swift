//
//  FilterSectionContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 14/10/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX

// MARK: - FilterTab Enum
enum FilterTab: CaseIterable, Hashable {
    case projects
    case reportedBy
    case date
    case incidentType

    var title: String {
        switch self {
        case .projects: return "projects".localizedString()
        case .reportedBy: return "reported_by".localizedString()
        case .date: return "date".localizedString()
        case .incidentType: return "incident_type".localizedString()
        }
    }

    static func filteredCases(includeIncidentType: Bool) -> [FilterTab] {
        includeIncidentType ? allCases : allCases.filter { $0 != .incidentType }
    }
}

// MARK: - Main View
struct FilterSectionContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject private var viewModel = FilterSectionViewModel()

    // Tabs & Search
    @State private var selectedTab: FilterTab = .projects
    @State private var searchText = Constants.EMPTY_STRING
    @State private var selectStartDate = false
    @State private var selectEndDate = false

    // Parent Bindings
    @Binding var noProjectSpecified: Bool
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var isActive: Bool
    @Binding var selectedProjectIds: [Int]
    @Binding var selectedResponsibleIds: [Int]
    @Binding var selectedIncidentIds: [Int]

    var isIncidentType: Bool = false
    var title: String

    // MARK: - Temporary Local States
    @State private var tempNoProjectSpecified = false
    @State private var tempStartDate: Date? = nil
    @State private var tempEndDate: Date? = nil
    @State private var tempSelectedProjectIds: [Int] = []
    @State private var tempSelectedResponsibleIds: [Int] = []
    @State private var tempSelectedIncidentIds: [Int] = []

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack {
                    contentBody
                    footerButtons
                }
                .onAppear(perform: setupInitialData)
            }
            .navigationBarTitle("filters".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true)
                }, image: Image(IC.INDICATORS.BLACK_BACKWARD_ARROW))

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("clear_all".localizedString(), action: clearAll)
                        .foregroundColor(Color.Blue.THEME)
                        .font(.medium(12.5))
                }
            }
        }
        .pickerViewerOverlay(viewerShown: $selectStartDate, title: "date_open".localizedString()) {
            DatePicker("", selection: Binding<Date>(
                get: { tempStartDate ?? Date() },
                set: { tempStartDate = $0 }
            ), in: ...Date.distantFuture, displayedComponents: .date)
            .modifier(DatePickerViewStyle())
        }
        .pickerViewerOverlay(viewerShown: $selectEndDate, title: "date_close".localizedString()) {
            DatePicker("", selection: Binding<Date>(
                get: { tempEndDate ?? (tempStartDate ?? Date()).addingTimeInterval(86400) },
                set: { tempEndDate = $0 }
            ), in: ((tempStartDate ?? Date()).addingTimeInterval(86400))..., displayedComponents: .date)
            .modifier(DatePickerViewStyle())
        }
    }

    // MARK: - Content Body
    private var contentBody: some View {
        HStack(spacing: 0) {
            sidebarTabs
                .frame(width: screenWidth / 3)
                .background(Color.Grey.PALE)

            ZStack {
                VStack {
                    switch selectedTab {
                    case .projects: projectsView
                    case .reportedBy: reportedByView
                    case .date: dateView
                    case .incidentType:
                        if isIncidentType { incidentTypeView }
                    }
                }
                .padding(.top, 15)
                .padding(.horizontal, 15)

                if viewModel.isLoading {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium)
                } else if viewModel.noDataFound {
                    "no_data_found".localizedString().viewRetry { retry() }
                } else if let error = viewModel.error {
                    error.viewRetry(isError: true) { retry() }
                }
            }
            .background(Color.white)
        }
    }

    // MARK: - Sidebar Tabs
    private var sidebarTabs: some View {
        VStack(spacing: 20) {
            ForEach(FilterTab.filteredCases(includeIncidentType: isIncidentType), id: \.self) { tab in
                sidebarTabRow(for: tab)
            }
            Spacer()
        }
    }

    private func sidebarTabRow(for tab: FilterTab) -> some View {
        let isActive = {
            switch tab {
            case .projects:
                return !tempSelectedProjectIds.isEmpty || tempNoProjectSpecified
            case .reportedBy:
                return !tempSelectedResponsibleIds.isEmpty
            case .incidentType:
                return !tempSelectedIncidentIds.isEmpty
            case .date:
                return tempStartDate != nil || tempEndDate != nil
            }
        }()

        return HStack(spacing: 8) {
            if isActive {
                Color.Blue.THEME.frame(width: 6, height: 6)
            }

            Text(tab.title)
                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                .font(selectedTab == tab ? .medium(14) : .regular(14))
            Spacer()
        }
        .padding(.leading, 10)
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(selectedTab == tab ? Color.white : Color.Grey.PALE)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTab = tab
            searchText = Constants.EMPTY_STRING
            viewModel.resetSearch(for: tab)
        }
    }

    // MARK: - Project View
    private var projectsView: some View {
        VStack {
            searchBar("search_projects".localizedString()) { value in
                viewModel.search(key: value, selectedItem: .group)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    noProjectSpecifiedView
                    ForEach(viewModel.searchProjects, id: \.groupId) { project in
                        ProjectListItemView(
                            groupDetail: project,
                            viewModel: viewModel,
                            isSelected: .constant(tempSelectedProjectIds.contains(Int(project.groupId) ?? -1)),
                            selectedProjectsIds: $tempSelectedProjectIds,
                            noProjectSpecified: $tempNoProjectSpecified
                        )
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - ReportedBy View
    private var reportedByView: some View {
        VStack {
            searchBar("search_user".localizedString()) { value in
                viewModel.search(key: value, selectedItem: .observer)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(viewModel.searchObserversUsersList, id: \.userId) { userData in
                        UserListItemView(
                            userData: userData,
                            viewModel: viewModel,
                            selectedResponsibleIds: $tempSelectedResponsibleIds,
                            selectedItem: .observer
                        )
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Date View
    private var dateView: some View {
        VStack(spacing: 25) {
            ThemeSelectionFieldView(
                title: "date_open".localizedString(),
                value: tempStartDate?.startDateText(),
                isSelected: $selectStartDate
            ) { tempStartDate = nil }

            ThemeSelectionFieldView(
                title: "date_close".localizedString(),
                value: tempEndDate?.endDateText(),
                isSelected: $selectEndDate
            ) { tempEndDate = nil }

            Spacer()
        }
    }

    // MARK: - Incident Type View
    private var incidentTypeView: some View {
        VStack {
            searchBar("search_incident_type".localizedString()) { _ in }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(filteredIncidentTypes, id: \.id) { type in
                        IncidentTypeRow(incidentType: type, selectedIncidentTypeIds: $tempSelectedIncidentIds)
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Search Bar Helper
    private func searchBar(_ placeholder: String, onChange: @escaping (String) -> Void) -> some View {
        SearchFieldInputView(
            onEditingChanged: {},
            onDone: { closeKeyboard() },
            text: $searchText,
            placeholder: placeholder.localizedString(),
            closeButtonActive: false,
            image: IC.ACTIONS.SEARCH_BLACK,
            foregroundColor: Color.Black.DUSK_TWO,
            font: .regular(15)
        )
        .onChange(of: searchText, perform: onChange)
    }

    // MARK: - No Project Specified
    private var noProjectSpecifiedView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    Image(IC.PLACEHOLDER.GROUP)

                    if tempNoProjectSpecified {
                        Color.Blue.THEME.opacity(0.25)
                        Image(IC.ACTIONS.TICK)
                    }
                }
                .frame(width: 58.5, height: 58.5)
                .cornerRadius(29.25)

                VStack(spacing: 5) {
                    LeftAlignedHStack(Text("no_project".localizedString())
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.medium(14)))

                    LeftAlignedHStack(Text(String(format:"show_all_items_not_in_project".localizedString(), title))
                        .foregroundColor(Color.Grey.SLATE)
                        .font(.regular(13)))
                }
                .padding(.leading, 19)

                Spacer()
            }

            Divider()
                .background(Color.Blue.VERY_LIGHT)
                .frame(height: 0.5)
                .padding([.top, .bottom], 12.5)
        }
        .onTapGesture {
            tempNoProjectSpecified.toggle()
            viewModel.deRegisterGroup()
            tempSelectedProjectIds = []
        }
    }

    // MARK: - Footer Buttons
    private var footerButtons: some View {
        HStack {
            Button("close".localizedString()) {
                viewControllerHolder?.dismiss(animated: true)
            }
            .foregroundColor(Color.Grey.SLATE)
            .font(.regular(16.2))
            .frame(maxWidth: .infinity, minHeight: 85)

            Divider().frame(width: 1, height: 37).foregroundColor(Color.Silver.TWO)

            Button("apply".localizedString()) {
                applyFilterChanges()
                isActive.toggle()
                viewControllerHolder?.dismiss(animated: true)
            }
            .foregroundColor(Color.Blue.THEME)
            .font(.regular(16.2))
            .frame(maxWidth: .infinity, minHeight: 85)
        }
        .background(Color.white)
        .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
    }

    // MARK: - Setup, Apply, Clear
    private func setupInitialData() {
        tempNoProjectSpecified = noProjectSpecified
        tempStartDate = startDate
        tempEndDate = endDate
        tempSelectedProjectIds = selectedProjectIds
        tempSelectedResponsibleIds = selectedResponsibleIds
        tempSelectedIncidentIds = selectedIncidentIds

        viewModel.fetchProjectAndUsersList(
            selectedGroupIds: tempSelectedProjectIds,
            selectedResponsibleIds: tempSelectedResponsibleIds
        )
    }

    private func applyFilterChanges() {
        noProjectSpecified = tempNoProjectSpecified
        startDate = tempStartDate
        endDate = tempEndDate
        selectedProjectIds = tempSelectedProjectIds
        selectedResponsibleIds = tempSelectedResponsibleIds
        selectedIncidentIds = tempSelectedIncidentIds
    }

    private func clearAll() {
        tempNoProjectSpecified = false
        tempSelectedProjectIds = []
        tempSelectedResponsibleIds = []
        tempSelectedIncidentIds = []
        tempStartDate = nil
        tempEndDate = nil
    }

    private func retry() {
        switch selectedTab {
        case .projects: viewModel.fetchGroupList(searchKey: searchText)
        case .reportedBy: viewModel.fetchUsersList(selecedItem: .observer)
        case .incidentType, .date: break
        }
    }

    // MARK: - Incident Type Filter
    private var filteredIncidentTypes: [IncidentType] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return IncidentType.allCases
        } else {
            return IncidentType.allCases.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}


// MARK: - Subviews
extension FilterSectionContentView {
    struct ProjectListItemView: View {
        let groupDetail: GroupData
        var viewModel: FilterSectionViewModel
        @Binding var isSelected: Bool
        @Binding var selectedProjectsIds: [Int]
        @Binding var noProjectSpecified: Bool

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        WebUrlImage(url: groupDetail.groupImage.url, placeholderImage: Image(IC.PLACEHOLDER.GROUP))

                        if isSelected {
                            Color.Blue.THEME.opacity(0.25)

                            Image(IC.ACTIONS.TICK)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: 58.5, height: 58.5)
                    .cornerRadius(29.25)

                    VStack(spacing: 5) {
                        LeftAlignedHStack(
                            Text(groupDetail.groupName)
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(14))
                                .lineLimit(1)
                        )

                        LeftAlignedHStack(
                            Text(groupDetail.groupCode)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                        )
                    }
                    .padding(.leading, 19)

                    Spacer()
                }

                Divider()
                    .background(Color.Blue.VERY_LIGHT)
                    .frame(height: 0.5)
                    .padding([.top, .bottom], 12.5)
            }
            .onTapGesture {
                noProjectSpecified = false
                let id = Int(groupDetail.groupId) ?? -1
                
                if let index = selectedProjectsIds.firstIndex(of: id) {
                    // If exists → remove
                    selectedProjectsIds.remove(at: index)
                } else {
                    // If not exists → add
                    selectedProjectsIds.append(id)
                }
                viewModel.registerGroup(groupData: groupDetail, isSelected: !isSelected)
                isSelected.toggle()
            }
        }
    }

}

extension FilterSectionContentView {
    struct UserListItemView: View {
        let userData: UserData
        var viewModel: FilterSectionViewModel
        @Binding var selectedResponsibleIds: [Int]
        var selectedItem: FilterType

        var body: some View {
            let isSelected = selectedResponsibleIds.contains{ $0 == userData.userId
            }
            
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    
                    imageViewer(isSelected: isSelected)

                    VStack(spacing: 5) {
                        LeftAlignedHStack(
                            Text(userData.name)
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(14))
                                .lineLimit(1)
                        )

                        LeftAlignedHStack(
                            Text(userData.email)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                        )
                    }
                    .padding(.leading, 19)

                    Spacer()
                }

                Divider()
                    .background(Color.Blue.VERY_LIGHT)
                    .frame(height: 0.5)
                    .padding([.top, .bottom], 12.5)
            }
            .onTapGesture {
                let id = userData.userId
               
                if let index = selectedResponsibleIds.firstIndex(of: id) {
                    // If exists → remove
                    selectedResponsibleIds.remove(at: index)
                } else {
                    // If not exists → add
                    selectedResponsibleIds.append(id)
                }
                viewModel.registerUser(userData: userData, isSelected: !isSelected, selectedItem: selectedItem)
            }
        }
        
        private func imageViewer(isSelected: Bool) -> some View {
            ZStack {
                WebUrlImage(url: userData.image.url, placeholderImage: Image(IC.PLACEHOLDER.USER))

                if isSelected {
                    Color.Blue.THEME.opacity(0.25)

                    Image(IC.ACTIONS.TICK)
                } else {
                    Color.clear
                }
            }
            .frame(width: 58.5, height: 58.5)
            .cornerRadius(29.25)
        }
    }
    
    struct IncidentTypeRow: View {
        let incidentType: IncidentType
        @Binding var selectedIncidentTypeIds: [Int]
        
        var body: some View {
            let isSelected = selectedIncidentTypeIds.contains { $0 == incidentType.id }
            HStack {
                Text(incidentType.title)
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.regular(12))
                
                Spacer()
                
                Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
            }
            .frame(minHeight: 40)
            .contentShape(Rectangle())
            .onTapGesture {
                let id = incidentType.id
               print(id)
                if let index = selectedIncidentTypeIds.firstIndex(of: id) {
                    // If exists → remove
                    selectedIncidentTypeIds.remove(at: index)
                } else {
                    // If not exists → add
                    selectedIncidentTypeIds.append(id)
                }
                
                print(selectedIncidentTypeIds)
            }
        }
    }


}
