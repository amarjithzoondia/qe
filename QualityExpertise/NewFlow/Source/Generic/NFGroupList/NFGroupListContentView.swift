//
//  NFGroupListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX

struct NFGroupListContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject private var viewModel: NFGroupListViewModel
    @State var searchText = ""
    @State var isFromViewGroup = false
    @State var isFromCreateObservation = false
    @State var isFromInviteUsers = false
    @Binding var isActive: Bool
    @Binding var groupData: GroupData?
    @State var closeButtonActive = false
    let updateGroupPublisher = NotificationCenter.default.publisher(for: .UPDATE_GROUP)
    let deleteGroupPublisher = NotificationCenter.default.publisher(for: .DELETE_GROUP)
    let updateListPublisher = NotificationCenter.default.publisher(for: .UPDATE_GROUP_LIST)
    
    init(
            isFromViewGroup: Bool,
            isFromCreateObservation: Bool = false,
            isActive: Binding<Bool>,
            groupData: Binding<GroupData?>
        ) {
            _viewModel = StateObject(wrappedValue: NFGroupListViewModel(isFromViewGroup: isFromViewGroup))
            _isFromViewGroup = State(initialValue: isFromViewGroup)
            _isFromCreateObservation = State(initialValue: isFromCreateObservation)
            _isActive = isActive
            _groupData = groupData
        }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                } else if viewModel.noDataFound {
                    "no_projects_found".localizedString().viewRetry {
                        viewModel.onRetry()
                    }
                } else if let error = viewModel.error {
                    error.viewRetry(isError: true) {
                        viewModel.onRetry()
                    }
                } else {
                    VStack {
                        SearchFieldInputView(
                            onEditingChanged: {},
                            onDone: {
                                closeKeyboard()
                            },
                            text: $searchText,
                            placeholder: "search_projects".localizedString(),
                            closeButtonActive: closeButtonActive
                        )
                        .onChange(of: searchText, perform: { value in
                            if searchText == "" {
                                closeButtonActive = false
                            } else {
                                closeButtonActive = true
                            }
                            viewModel.search(key: searchText)
                        })
                        
                        VStack {
                            LeftAlignedHStack(
                                Text("projects_list".localizedString())
                                    .foregroundColor(Color.Grey.STEEL)
                                    .font(.semiBold(12.5))
                            )
                            
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.searchGroups, id: \.groupId) { group in
                                        ListItemView(groupDetail: group, viewModel: viewModel, isSelected: .constant(group.isSelected ?? false), isFromViewGroup: isFromViewGroup, isFromCreateObservation: isFromCreateObservation
                                        )
                                    }
                                }
                                .onAppear {
                                    if let groupData = groupData {
                                        if let index = viewModel.searchGroups.firstIndex(where: { $0.groupId == groupData.groupId }) {
                                            viewModel.searchGroups[index].isSelected = true
                                            viewModel.groupId = groupData.groupId
                                            viewModel.groupCode = groupData.groupCode
                                            viewModel.groupData = groupData
                                            
                                        }
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                            }
                        }
                        .padding(.top, 34.5)
                    }
                    .padding(.top, 21.5)
                    .padding(.bottom, (isFromViewGroup || isFromCreateObservation) ? 0 : 20 + 21 + 45)
                    .padding(.horizontal, 28)
                    
                    if !isFromViewGroup && !isFromCreateObservation {
                        VStack {
                            Spacer()
                            
                            Button {
                                self.groupData = viewModel.groupData
                                self.isActive.toggle()
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            } label: {
                                Text("invite".localizedString())
                                    .foregroundColor(Color.white)
                                    .font(.medium(16))
                                    .frame(maxWidth: .infinity, minHeight: 45)
                            }
                            .frame(maxWidth: .infinity, minHeight: 45)
                            .background(Color.Blue.THEME)
                            .cornerRadius(22.5)
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitle("projects".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.groupData != nil {
                            self.groupData = viewModel.groupData
                            isActive = true
                        }
                        viewControllerHolder?.dismiss(animated: true)
                    }, label: {
                        if isFromCreateObservation && viewModel.searchGroups.count > 0 {
                            Text("apply".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(15))
                        }
                    })
                        .disabled(!isFromCreateObservation)
                }
            }
            .onReceive(updateGroupPublisher) { (output) in
                viewModel.fetchGroupList(searchKey: "", isFromViewGroup: isFromViewGroup)
            }
            .onReceive(deleteGroupPublisher) { (output) in
                viewModel.fetchGroupList(searchKey: "", isFromViewGroup: isFromViewGroup)
            }
            .onReceive(updateListPublisher, perform: { (output) in
                viewModel.fetchGroupList(searchKey: "", isFromViewGroup: isFromViewGroup)
            })
            .listenToAppNotificationClicks()
        }
    }
}

extension NFGroupListContentView {
    struct ListItemView: View {
        let groupDetail: GroupData
        var viewModel: NFGroupListViewModel
        @Binding var isSelected: Bool
        var isFromViewGroup: Bool
        var isFromCreateObservation: Bool
        @Environment(\.viewController) private var viewControllerHolder: UIViewController?
        var userType: UserType = UserManager.getLoginedUser()?.userType ?? .normalUser
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    WebUrlImage(url: groupDetail.groupImage.url, placeholderImage: Image(IC.PLACEHOLDER.GROUP))
                        .frame(width: 58.5, height: 58.5)
                        .cornerRadius(29.25)
                    
                    VStack(spacing: 5) {
                        LeftAlignedHStack(
                            Text(groupDetail.groupName)
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(14))
                        )
                        
                        LeftAlignedHStack(
                            Text(groupDetail.groupCode)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                        )
                        

                        if isFromViewGroup,
                           let roleDescription = groupDetail.userRole?.description,
                           !roleDescription.isEmpty {

                            LeftAlignedHStack(
                                VStack {
                                    Text(roleDescription)
                                        .foregroundColor(.white)
                                        .font(.regular(12))
                                        .padding(.horizontal, 5)
                                        .frame(minHeight: 25)
                                }
                                .background(Color.Blue.THEME)
                                .cornerRadius(12.5)
                            )
                        }
                    }
                    .padding(.leading, 19)
                    
                    Spacer()
                    
                    if isFromCreateObservation {
                        Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                            .renderingMode(.original)
                            .frame(width: 18.0, height: 18.0)
                            .padding(.trailing, 5)
                    }
                }
                
                Divider()
                    .background(Color.Blue.VERY_LIGHT)
                    .frame(height: 0.5)
                    .padding([.top, .bottom], 12.5)
            }
            .onTapGesture {
                if !isFromCreateObservation {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        NFGroupDetailsContentView(viewModel: .init(groupId: groupDetail.groupId, groupCode: groupDetail.groupCode), searchText: "")
                            .localize()
                    }
                } else if !isSelected {
                    viewModel.register(groupDetail: groupDetail, isSelected: true)
                    isSelected = true
                }
            }
        }
    }

}

struct NFGroupListContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFGroupListContentView(isFromViewGroup: true, isActive: .constant(false),groupData: .constant(GroupData.dummy()))
    }
}
