//
//  FilterObservationListContentView.swift
// ALNASR
//
//  Created by developer on 28/02/22.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX

struct FilterObservationListContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = FilterObservationViewModel()
    @State var selectedItem: FilterType = .status
    @Binding var isOpenObservationSelected: Bool
    @Binding var isClosedObservationSelected: Bool
    @Binding var selectedGroupsIds: [Int]
    @Binding var selectedObserversIds: [Int]
    @Binding var selectedResponsiblePersonsIds: [Int]
    @State private var selectStartDate = false
    @State private var selectEndDate = false
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var noGroupSpecified: Bool
    @State private var searchText: String = Constants.EMPTY_STRING
    @Binding var isActive: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        HStack {
                            listView
                                .frame(width: screenWidth / 3)
                                .frame(maxHeight: .infinity)
                                .background(Color.Grey.PALE.edgesIgnoringSafeArea(.all))
                            
                            VStack {
                                ZStack {
                                    VStack {
                                        switch selectedItem {
                                        case .status:
                                            statusView
                                            
                                        case .group:
                                            groupView
                                                .onAppear {
                                                    viewModel.fetchGroupList(searchKey: "", selectedIds: selectedGroupsIds)
                                                }
                                            
                                        case .observer:
                                            observersListView
                                                .onAppear {
                                                    viewModel.fetchUsersList(selectedIds: selectedObserversIds, selecedItem: .observer)
                                                }
                                            
                                        case .responsible:
                                            responsiblePersonsListView
                                                .onAppear {
                                                    viewModel.fetchUsersList(selectedIds: selectedResponsiblePersonsIds, selecedItem: .responsible)
                                                }
                                            
                                        case .date:
                                            dateView
                                        }
                                    }
                                    .padding(.top, 15)
                                    .padding(.horizontal, 15)
                                    
                                    if viewModel.isLoading {
                                        Color.black
                                            .opacity(0.10)
                                            .edgesIgnoringSafeArea(.all)
                                        VStack {
                                            LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                                        }
                                    } else if viewModel.noDataFound && selectedItem != .status && selectedItem != .date {
                                        "no_data_found".localizedString()
                                            .viewRetry {
                                                retry()
                                        }
                                    } else if let error = viewModel.error {
                                        if selectedItem != .status && selectedItem != .date {
                                            error.viewRetry(isError: true) {
                                                retry()
                                            }
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                        }
                    }
                    
                    Spacer ()
                    
                    VStack {
                        HStack {
                            Button {
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            } label: {
                                Text("close".localizedString())
                                    .foregroundColor(Color.Grey.SLATE)
                                    .font(.regular(16.2))
                                    .frame(maxWidth: .infinity, minHeight: 85)
                            }
                            
                            Divider()
                                .frame(width: 1, height: 37, alignment: .center)
                                .foregroundColor(Color.Silver.TWO)
                            
                            Button {
                                setFilterData()
                                isActive.toggle()
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            } label: {
                                Text("apply".localizedString())
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.regular(16.2))
                                    .frame(maxWidth: .infinity, minHeight: 85)
                            }
                        }
                    }
                    .background(Color.white)
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                }
                
            }
            .navigationBarTitle("filters".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }, image: Image(IC.INDICATORS.BLACK_BACKWARD_ARROW))
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        clearAll()
                    } label: {
                        Text("clear_all".localizedString())
                            .foregroundColor(Color.Blue.THEME)
                            .font(.medium(12.5))
                    }
                }
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: $selectStartDate, title: "date_open".localizedString()) {
            DatePicker("",
                       selection: Binding<Date>(
                           get: { self.startDate ?? Date() },
                           set: { self.startDate = $0 }
                       ),
                       in: ...Date.distantFuture,
                       displayedComponents: .date)
                .modifier(DatePickerViewStyle())
        }
        .pickerViewerOverlay(viewerShown: $selectEndDate, title: "date_close".localizedString()) {
            DatePicker("",
                       selection: Binding<Date>(
                           get: { self.endDate ?? (self.startDate ?? Date()).addingTimeInterval(86400) }, // default to +1 day
                           set: { self.endDate = $0 }
                       ),
                       in: ((self.startDate ?? Date()).addingTimeInterval(86400))...,
                       displayedComponents: .date)
                .modifier(DatePickerViewStyle())
        }
        .onChange(of: selectStartDate) { newStartDate in
            if startDate == nil {
                startDate = Date()
            }
            
            // Ensure endDate is always >= startDate
            if let start = startDate {
                endDate = start.addingTimeInterval(86400)
            }
        }
    }
    
    var statusView: some View {
        VStack {
            HStack {
                Text("open_observations".localizedString())
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.regular(12))
                
                Spacer()
                
                Image(isOpenObservationSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
            }
            .frame(minHeight: 40)
            .onTapGesture {
                isOpenObservationSelected.toggle()
                isClosedObservationSelected = false
            }
            
            HStack {
                Text("closed_observations".localizedString())
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.regular(12))
                
                Spacer()
                
                Image(isClosedObservationSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
            }
            .frame(minHeight: 40)
            .onTapGesture {
                isClosedObservationSelected.toggle()
                isOpenObservationSelected = false
            }
        }
    }
    
    var groupView: some View {
        VStack {
            SearchFieldInputView(
                onEditingChanged: {},
                onDone: {
                    closeKeyboard()
                },
                text: $searchText,
                placeholder: "search".localizedString(),
                closeButtonActive: false,
                image: IC.ACTIONS.SEARCH_BLACK,
                foregroundColor: Color.Black.DUSK_TWO,
                font: .regular(15)
                
            )
            .onChange(of: searchText, perform: { value in
                viewModel.search(key: searchText, selectedItem: .group)
            })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        ZStack {
                            Image(IC.PLACEHOLDER.GROUP)
                            
                            if noGroupSpecified {
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
                                Text("no_group".localizedString())
                                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                    .font(.medium(14))
                                    .lineLimit(1)
                            )
                            
                            LeftAlignedHStack(
                                Text("show_all_observations".localizedString())
                                    .foregroundColor(Color.Grey.SLATE)
                                    .font(.regular(13))
                                    .lineLimit(2)
                            )
                        }
                        .padding(.leading, 19)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        noGroupSpecified.toggle()
                        if noGroupSpecified {
                            viewModel.searchGroups.indices.forEach({viewModel.searchGroups[$0].isSelected = false})
                        }
                    }
                    
                    Divider()
                        .background(Color.Blue.VERY_LIGHT)
                        .frame(height: 0.5)
                        .padding([.top, .bottom], 12.5)
                    
                    ForEach(viewModel.searchGroups, id: \.groupId) { group in
                        GroupListItemView(groupDetail: group, viewModel: viewModel, isSelected: .constant(group.isSelected ?? false), noGroupSpecified: noGroupSpecified)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    var observersListView: some View {
        VStack {
            SearchFieldInputView(
                onEditingChanged: {},
                onDone: {
                    closeKeyboard()
                },
                text: $searchText,
                placeholder: "search".localizedString(),
                closeButtonActive: false,
                image: IC.ACTIONS.SEARCH_BLACK,
                foregroundColor: Color.Black.DUSK_TWO,
                font: .regular(15)
            )
            .onChange(of: searchText, perform: { value in
                viewModel.search(key: searchText, selectedItem: .observer)
            })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.searchObserversUsersList, id: \.userId) { userData in
                        UserListItemView(userData: userData, viewModel: viewModel, isSelected: .constant(userData.isSelected ?? false), selectedItem: .observer)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    var responsiblePersonsListView: some View {
        VStack {
            SearchFieldInputView(
                onEditingChanged: {},
                onDone: {
                    closeKeyboard()
                },
                text: $searchText,
                placeholder: "search".localizedString(),
                closeButtonActive: false,
                image: IC.ACTIONS.SEARCH_BLACK,
                foregroundColor: Color.Black.DUSK_TWO,
                font: .regular(15)
            )
            .onChange(of: searchText, perform: { value in
                viewModel.search(key: searchText, selectedItem: .responsible)
            })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.searchresponsiblePersonsList, id: \.userId) { userData in
                        UserListItemView(userData: userData, viewModel: viewModel, isSelected: .constant(userData.isSelected ?? false), selectedItem: .responsible)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    var dateView: some View {
        VStack(spacing: 25) {
            ThemeSelectionFieldView(title: "date_open".localizedString(),
                                    value: startDate?.startDateText(),
                                    isSelected: $selectStartDate, action: {
                startDate = nil
            })
                    .onChange(of: startDate) { newValue in
                    }
            
            ThemeSelectionFieldView(title: "date_close".localizedString(),
                                    value: endDate?.endDateText(),
                                    isSelected: $selectEndDate, action: {
                endDate = nil
            })
                    .onChange(of: endDate) { newValue in
                    }
        }
    }
    
    func setFilterData() {
        if let selectedGroupsIds = viewModel.selectedGroupsIds {
            self.selectedGroupsIds = selectedGroupsIds
        }
        
        if let selectedObserversIds = viewModel.selectedObserversIds {
            self.selectedObserversIds = selectedObserversIds
        }
        
        if let selectedResponsiblePersonsIds = viewModel.selectedResponsiblePersonsIds {
            self.selectedResponsiblePersonsIds = selectedResponsiblePersonsIds
        }
    }
    
    func clearAll() {
        // Reset observation filters
        isOpenObservationSelected = false
        isClosedObservationSelected = false
        
        // Reset groups
        viewModel.searchGroups.indices.forEach { viewModel.searchGroups[$0].isSelected = false }
        viewModel.selectedGroupsIds = []
        selectedGroupsIds = []
        
        // Reset observers
        viewModel.searchObserversUsersList.indices.forEach { viewModel.searchObserversUsersList[$0].isSelected = false }
        viewModel.selectedObserversIds = []
        selectedObserversIds = []
        
        // Reset responsible persons
        viewModel.searchresponsiblePersonsList.indices.forEach { viewModel.searchresponsiblePersonsList[$0].isSelected = false }
        viewModel.selectedResponsiblePersonsIds = []
        selectedResponsiblePersonsIds = []
        
        // Reset group toggle
        noGroupSpecified = false
        
        // Reset dates
        startDate = nil
        endDate = nil
    }

    
    var listView: some View {
        VStack {
            ForEach(FilterType.allCases) { filterType in
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        if filterType == .status {
                            if isOpenObservationSelected || isClosedObservationSelected {
                                Color.Blue.THEME
                                    .frame(width: 6, height: 6)
                            }
                        } else if filterType == .group {
                            if viewModel.selectedGroupsIds != [] || selectedGroupsIds != [] {
                                Color.Blue.THEME
                                    .frame(width: 6, height: 6)
                            }
                        } else if filterType == .observer {
                            if viewModel.selectedObserversIds != [] || selectedObserversIds != [] {
                                Color.Blue.THEME
                                    .frame(width: 6, height: 6)
                            }
                        } else if filterType == .responsible {
                            if viewModel.selectedResponsiblePersonsIds != [] || selectedResponsiblePersonsIds != [] {
                                Color.Blue.THEME
                                    .frame(width: 6, height: 6)
                            }
                        } else {
                            if startDate != nil || endDate != nil {
                                Color.Blue.THEME
                                    .frame(width: 6, height: 6)
                            }
                        }
                        
                        Text(filterType.description)
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(filterType == selectedItem ? .medium(14) : .regular(14))
                        
                        Spacer()
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 5)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(filterType == selectedItem ? Color.white : Color.Grey.PALE)
                .onTapGesture {
                    selectedItem = filterType
                }
            }
            
            Spacer()
        }
    }
    
    func retry() {
        if selectedItem == .group {
            viewModel.fetchGroupList(searchKey: searchText, selectedIds: selectedGroupsIds)
        } else if selectedItem == .observer {
            viewModel.fetchUsersList(selectedIds: selectedObserversIds, selecedItem: .observer)
        } else {
            viewModel.fetchUsersList(selectedIds: selectedResponsiblePersonsIds, selecedItem: .responsible)
        }
    }
}

extension FilterObservationListContentView {
    struct GroupListItemView: View {
        let groupDetail: GroupData
        var viewModel: FilterObservationViewModel
        @Binding var isSelected: Bool
        @State var noGroupSpecified: Bool
        
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
                viewModel.registerGroup(groupData: groupDetail, isSelected: !isSelected)
                isSelected.toggle()
                if isSelected {
                    noGroupSpecified = false
                }
            }
        }
    }

}

extension FilterObservationListContentView {
    struct UserListItemView: View {
        let userData: UserData
        var viewModel: FilterObservationViewModel
        @Binding var isSelected: Bool
        var selectedItem: FilterType
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
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
                viewModel.registerUser(userData: userData, isSelected: !isSelected, selectedItem: selectedItem)
                isSelected.toggle()
            }
        }
    }

}

