//
//  NFFilterObservationListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX

struct NFFilterObservationListContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = NFFilterObservationViewModel()
    @State var selectedItem: NFFilterType = .status

    // MARK: - Actual Bindings
    @Binding var isOpenObservationSelected: Bool
    @Binding var isClosedObservationSelected: Bool
    @Binding var selectedGroupsIds: [Int]
    @Binding var selectedObserversIds: [Int]
    @Binding var selectedResponsiblePersonsIds: [Int]
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var noGroupSpecified: Bool
    @Binding var isActive: Bool

    // MARK: - Temporary State
    @State private var tempIsOpenObservationSelected: Bool = false
    @State private var tempIsClosedObservationSelected: Bool = false
    @State private var tempSelectedGroupsIds: [Int] = []
    @State private var tempSelectedObserversIds: [Int] = []
    @State private var tempSelectedResponsiblePersonsIds: [Int] = []
    @State private var tempStartDate: Date? = nil
    @State private var tempEndDate: Date? = nil
    @State private var tempNoGroupSpecified: Bool = false
    @State private var selectStartDate = false
    @State private var selectEndDate = false
    @State private var searchText: String = Constants.EMPTY_STRING

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack(spacing: 0) {
                        // Left filter list
                        listView
                            .frame(width: screenWidth / 3)
                            .frame(maxHeight: .infinity)
                            .background(Color.Grey.PALE.edgesIgnoringSafeArea(.all))

                        // Right filter content
                        VStack {
                            ZStack {
                                VStack {
                                    switch selectedItem {
                                    case .status:
                                        statusView
                                    case .project:
                                        projectView
                                    case .observer:
                                        observersListView
                                    case .responsible:
                                        responsiblePersonsListView
                                    case .date:
                                        dateView
                                    }
                                }
                                .padding(.top, 15)
                                .padding(.horizontal, 15)

                                // Loading / No Data / Error
                                if viewModel.isLoading {
                                    Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
                                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                                } else if viewModel.noDataFound && selectedItem != .status && selectedItem != .date {
                                    "no_data_found".localizedString().viewRetry { retry() }
                                } else if let error = viewModel.error, selectedItem != .status && selectedItem != .date {
                                    error.viewRetry(isError: true) { retry() }
                                }
                            }
                            Spacer()
                        }
                        .onAppear {
                            initializeTempState()
                            viewModel.fetchProjectAndUsersList(
                                selectedGroupIds: selectedGroupsIds,
                                selectedResponsibleIds: selectedResponsiblePersonsIds,
                                selectedObserversIds: selectedObserversIds
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                    }

                    Spacer()

                    // Bottom Buttons
                    HStack {
                        Button {
                            viewControllerHolder?.dismiss(animated: true, completion: nil)
                        } label: {
                            Text("close".localizedString())
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(16.2))
                                .frame(maxWidth: .infinity, minHeight: 85)
                        }

                        Divider().frame(width: 1, height: 37).foregroundColor(Color.Silver.TWO)

                        Button {
                            applyTempFilters()
                            isActive.toggle()
                            viewControllerHolder?.dismiss(animated: true, completion: nil)
                        } label: {
                            Text("apply".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(16.2))
                                .frame(maxWidth: .infinity, minHeight: 85)
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
                        clearTempFilters()
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
            DatePicker("", selection: Binding<Date>(get: { tempStartDate ?? Date() }, set: { tempStartDate = $0 }), in: ...Date.distantFuture, displayedComponents: .date)
                .modifier(DatePickerViewStyle())
        }
        .pickerViewerOverlay(viewerShown: $selectEndDate, title: "date_close".localizedString()) {
            DatePicker("", selection: Binding<Date>(get: { tempEndDate ?? (tempStartDate ?? Date()).addingTimeInterval(86400) }, set: { tempEndDate = $0 }), in: ((tempStartDate ?? Date()).addingTimeInterval(86400))..., displayedComponents: .date)
                .modifier(DatePickerViewStyle())
        }
        .onChange(of: selectStartDate) { _ in
            if tempStartDate == nil { tempStartDate = Date() }
            if let start = tempStartDate { tempEndDate = start.addingTimeInterval(86400) }
        }
    }

    // MARK: - Temp State Init
    private func initializeTempState() {
        tempIsOpenObservationSelected = isOpenObservationSelected
        tempIsClosedObservationSelected = isClosedObservationSelected
        tempSelectedGroupsIds = selectedGroupsIds
        tempSelectedObserversIds = selectedObserversIds
        tempSelectedResponsiblePersonsIds = selectedResponsiblePersonsIds
        tempStartDate = startDate
        tempEndDate = endDate
        tempNoGroupSpecified = noGroupSpecified
    }

    // MARK: - Apply Temp State
    private func applyTempFilters() {
        isOpenObservationSelected = tempIsOpenObservationSelected
        isClosedObservationSelected = tempIsClosedObservationSelected
        selectedGroupsIds = tempSelectedGroupsIds
        selectedObserversIds = tempSelectedObserversIds
        selectedResponsiblePersonsIds = tempSelectedResponsiblePersonsIds
        startDate = tempStartDate
        endDate = tempEndDate
        noGroupSpecified = tempNoGroupSpecified
    }

    // MARK: - Clear Temp State
    private func clearTempFilters() {
        tempIsOpenObservationSelected = false
        tempIsClosedObservationSelected = false
        tempSelectedGroupsIds = []
        tempSelectedObserversIds = []
        tempSelectedResponsiblePersonsIds = []
        tempStartDate = nil
        tempEndDate = nil
        tempNoGroupSpecified = false
    }

    // MARK: - Status View
    var statusView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("open_observations".localizedString()).foregroundColor(Color.Blue.DARK_BLUE_GREY).font(.regular(12))
                Spacer()
                Image(tempIsOpenObservationSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
            }
            .frame(minHeight: 40)
            .onTapGesture {
                tempIsOpenObservationSelected.toggle()
                tempIsClosedObservationSelected = false
            }

            HStack {
                Text("closed_observations".localizedString()).foregroundColor(Color.Blue.DARK_BLUE_GREY).font(.regular(12))
                Spacer()
                Image(tempIsClosedObservationSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
            }
            .frame(minHeight: 40)
            .onTapGesture {
                tempIsClosedObservationSelected.toggle()
                tempIsOpenObservationSelected = false
            }
        }
    }

    // MARK: - Project View
    var projectView: some View {
        VStack {
            SearchFieldInputView(
                onEditingChanged: {},
                onDone: { closeKeyboard() },
                text: $searchText,
                placeholder: "search".localizedString(),
                closeButtonActive: false,
                image: IC.ACTIONS.SEARCH_BLACK,
                foregroundColor: Color.Black.DUSK_TWO,
                font: .regular(15)
            )
            .onChange(of: searchText) { newValue in
                viewModel.search(key: newValue, selectedItem: .group)
            }


            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // No Project option
                    HStack(spacing: 10) {
                        ZStack {
                            Image(IC.PLACEHOLDER.GROUP)
                            if tempNoGroupSpecified {
                                Color.Blue.THEME.opacity(0.25)
                                Image(IC.ACTIONS.TICK)
                            }
                        }
                        .frame(width: 58.5, height: 58.5).cornerRadius(29.25)

                        VStack(spacing: 5) {
                            LeftAlignedHStack(Text("No Project").foregroundColor(Color.Blue.DARK_BLUE_GREY).font(.medium(14)))
                            LeftAlignedHStack(Text("Show all Observations that are not specified to any project.").foregroundColor(Color.Grey.SLATE).font(.regular(13)))
                        }.padding(.leading, 19)

                        Spacer()
                    }
                    .onTapGesture {
                        tempNoGroupSpecified.toggle()
                        if tempNoGroupSpecified { tempSelectedGroupsIds.removeAll() }
                    }

                    Divider().background(Color.Blue.VERY_LIGHT).frame(height: 0.5).padding(.vertical, 12.5)

                    ForEach(viewModel.searchGroups, id: \.groupId) { group in
                        GroupListItemView(
                            groupDetail: group,
                            viewModel: viewModel,
                            tempSelectedGroupsIds: $tempSelectedGroupsIds,
                            tempNoGroupSpecified: $tempNoGroupSpecified
                        )
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Observers View
    var observersListView: some View {
        VStack {
            SearchFieldInputView(
                onEditingChanged: {},
                onDone: { closeKeyboard() },
                text: $searchText,
                placeholder: "search".localizedString(),
                closeButtonActive: false,
                image: IC.ACTIONS.SEARCH_BLACK,
                foregroundColor: Color.Black.DUSK_TWO,
                font: .regular(15)
            )
            .onChange(of: searchText) { newValue in
                viewModel.search(key: newValue, selectedItem: .observer)
            }


            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(viewModel.searchObserversUsersList, id: \.userId) { user in
                        UserListItemView(
                            userData: user,
                            tempSelectedUserIds: $tempSelectedObserversIds
                        )
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Responsible Persons View
    var responsiblePersonsListView: some View {
        VStack {
            SearchFieldInputView(
                onEditingChanged: {},
                onDone: { closeKeyboard() },
                text: $searchText,
                placeholder: "search".localizedString(),
                closeButtonActive: false,
                image: IC.ACTIONS.SEARCH_BLACK,
                foregroundColor: Color.Black.DUSK_TWO,
                font: .regular(15)
            )
            .onChange(of: searchText) { newValue in
                viewModel.search(key: newValue, selectedItem: .responsible)
            }


            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(viewModel.searchresponsiblePersonsList, id: \.userId) { user in
                        UserListItemView(
                            userData: user,
                            tempSelectedUserIds: $tempSelectedResponsiblePersonsIds
                        )
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Date View
    var dateView: some View {
        VStack(spacing: 25) {
            ThemeSelectionFieldView(
                title: "date_open".localizedString(),
                value: tempStartDate?.startDateText(),
                isSelected: $selectStartDate,
                action: { tempStartDate = nil }
            )
            ThemeSelectionFieldView(
                title: "date_close".localizedString(),
                value: tempEndDate?.endDateText(),
                isSelected: $selectEndDate,
                action: { tempEndDate = nil }
            )
        }
    }

    // MARK: - Filter List (Left Sidebar)
    var listView: some View {
        VStack {
            ForEach(NFFilterType.allCases) { filterType in
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        // Blue dot indicator logic based on temp state
                        if filterType == .status, tempIsOpenObservationSelected || tempIsClosedObservationSelected {
                            Color.Blue.THEME.frame(width: 6, height: 6)
                        } else if filterType == .project, !tempSelectedGroupsIds.isEmpty || tempNoGroupSpecified {
                            Color.Blue.THEME.frame(width: 6, height: 6)
                        } else if filterType == .observer, !tempSelectedObserversIds.isEmpty {
                            Color.Blue.THEME.frame(width: 6, height: 6)
                        } else if filterType == .responsible, !tempSelectedResponsiblePersonsIds.isEmpty {
                            Color.Blue.THEME.frame(width: 6, height: 6)
                        } else if filterType == .date, tempStartDate != nil || tempEndDate != nil {
                            Color.Blue.THEME.frame(width: 6, height: 6)
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
                    searchText = Constants.EMPTY_STRING
                    viewModel.resetSearch(for: filterType)
                }
            }

            Spacer()
        }
    }


    // MARK: - Retry
    func retry() {
        if selectedItem == .project {
            viewModel.fetchGroupList(searchKey: searchText, selectedIds: tempSelectedGroupsIds)
        } else if selectedItem == .observer {
            viewModel.fetchUsersList(selectedIds: tempSelectedObserversIds, selecedItem: .observer)
        } else if selectedItem == .responsible {
            viewModel.fetchUsersList(selectedIds: tempSelectedResponsiblePersonsIds, selecedItem: .responsible)
        }
    }
}

// MARK: - Group List Item
extension NFFilterObservationListContentView {
    struct GroupListItemView: View {
        let groupDetail: GroupData
        @ObservedObject var viewModel: NFFilterObservationViewModel
        @Binding var tempSelectedGroupsIds: [Int]
        @Binding var tempNoGroupSpecified: Bool

        var isSelected: Bool { tempSelectedGroupsIds.contains(Int(groupDetail.groupId) ?? -1) }

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        WebUrlImage(url: groupDetail.groupImage.url, placeholderImage: Image(IC.PLACEHOLDER.GROUP))
                        if isSelected {
                            Color.Blue.THEME.opacity(0.25)
                            Image(IC.ACTIONS.TICK)
                        }
                    }
                    .frame(width: 58.5, height: 58.5).cornerRadius(29.25)

                    VStack(spacing: 5) {
                        LeftAlignedHStack(Text(groupDetail.groupName).foregroundColor(Color.Blue.DARK_BLUE_GREY).font(.medium(14)))
                        LeftAlignedHStack(Text(groupDetail.groupCode).foregroundColor(Color.Grey.SLATE).font(.regular(13)))
                    }.padding(.leading, 19)

                    Spacer()
                }
                Divider().background(Color.Blue.VERY_LIGHT).frame(height: 0.5).padding(.vertical, 12.5)
            }
            .onTapGesture {
                if isSelected {
                    tempSelectedGroupsIds.removeAll { $0 == Int(groupDetail.groupId) }
                } else {
                    tempSelectedGroupsIds.append(Int(groupDetail.groupId) ?? -1)
                    tempNoGroupSpecified = false
                }
            }
        }
    }
}

// MARK: - User List Item
extension NFFilterObservationListContentView {
    struct UserListItemView: View {
        let userData: UserData
        @Binding var tempSelectedUserIds: [Int]

        var isSelected: Bool { tempSelectedUserIds.contains(userData.userId) }

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        WebUrlImage(url: userData.image.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                        if isSelected {
                            Color.Blue.THEME.opacity(0.25)
                            Image(IC.ACTIONS.TICK)
                        }
                    }
                    .frame(width: 58.5, height: 58.5).cornerRadius(29.25)

                    VStack(spacing: 5) {
                        LeftAlignedHStack(Text(userData.name).foregroundColor(Color.Blue.DARK_BLUE_GREY).font(.medium(14)))
                        LeftAlignedHStack(Text(userData.email).foregroundColor(Color.Grey.SLATE).font(.regular(13)).lineLimit(1))
                    }.padding(.leading, 19)

                    Spacer()
                }
                Divider().background(Color.Blue.VERY_LIGHT).frame(height: 0.5).padding(.vertical, 12.5)
            }
            .onTapGesture {
                if isSelected {
                    tempSelectedUserIds.removeAll { $0 == userData.userId }
                } else {
                    tempSelectedUserIds.append(userData.userId)
                }
            }
        }
    }
}
