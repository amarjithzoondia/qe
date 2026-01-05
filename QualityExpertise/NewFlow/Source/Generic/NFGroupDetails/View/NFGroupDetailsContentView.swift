//
//  NFGroupDetailsContentView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX

struct NFGroupDetailsContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: NFGroupDetailsViewModel
    @State private var isSearchFieldActive: Bool = false
    @State var searchText: String = Constants.EMPTY_STRING
    let updateGroupPublisher = NotificationCenter.default.publisher(for: .UPDATE_GROUP)
    @State private var password: String = Constants.EMPTY_STRING
    @State private var userId: Int = -1
    @State private var userName: String = Constants.EMPTY_STRING
    @State private var alertShownForHandOver: Bool = false
    @State private var alertForIncorrectPassword: Bool = false
    @State private var alertShownForDeleteGroup: Bool = false
    @State private var isActive: Bool = false
    @State private var showGroupImage = false
    @State private var alertShownForExitGroup: Bool = false
    var userType: UserType = UserManager.getLoginedUser()?.userType ?? .normalUser
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if let error = viewModel.error {
                        VStack {
                            Spacer()
                            ErrorRetryView(retry: {
                                viewModel.getGroupDetails()
                            },title: "error".localizedString() , message: error.message, isDarkMode: false, isError: true)
                            Spacer()
                        }
                        .padding(.horizontal, 27.5)
                    } else {
                        contentView
                    }
                }
            }
            .navigationBarTitle("project".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
                
                
                    
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.error == nil {
                        if userType == .appAdmin || viewModel.groupDetails?.isAdmin ?? false {
                            HStack(spacing: 15) {
                                Button {
                                    viewControllerHolder?.present(style: .overCurrentContext) {
                                        NFCreateGroupContentView(
                                            viewModel: .init(
                                                isEditing: true,
                                                groupName: viewModel.groupDetails?.groupName ?? "",
                                                description: viewModel.groupDetails?.description ?? "",
                                                image: viewModel.groupDetails?.groupImage ?? "",
                                                groupCode: viewModel.groupDetails?.groupCode ?? ""
                                            )
                                        )
                                        .localize()
                                    }
                                } label: {
                                    Image(IC.ACTIONS.EDIT_BLACK)
                                }
                            }
                        }
                    }
                }

            }
            .onChange(of: searchText) { (value) in
                viewModel.search(key: searchText)
            }
            .onChange(of: userId, perform: { (value) in
                alertShownForHandOver.toggle()
            })
            .onChange(of: isActive, perform: { (value) in
                alertShownForDeleteGroup.toggle()
            })
            .onReceive(updateGroupPublisher) { (output) in
                viewModel.getGroupDetails()
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
        .loadingOverlay(isLoading: viewModel.isLoading)
        .imageViewerOverlay(viewerShown: $showGroupImage, images: [viewModel.groupDetails?.groupImage ?? ""])
        .pickerViewerOverlay(viewerShown: $alertShownForHandOver, title: "confirm".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text(String(format: NSLocalizedString("handover_admin_rights", comment: ""), userName))
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        alertShownForHandOver.toggle()
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
                        alertShownForHandOver.toggle()
                        handOverSuperAdminRights()
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
        .pickerViewerOverlay(viewerShown: $alertForIncorrectPassword, title: "failed".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text(viewModel.statusMessage)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Button {
                        alertForIncorrectPassword.toggle()
                    } label: {
                        Text("okay".localizedString())
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                    }
                    .frame(width: 80, height: 35)
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.top, 10)
                .padding(.trailing, 15)
                .padding(.bottom, 15)
            }
        }
        .pickerViewerOverlay(viewerShown: $alertShownForDeleteGroup, title: "delete_project".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("delete_group_warning".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        alertShownForDeleteGroup.toggle()
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
                        alertShownForDeleteGroup.toggle()
                        deleteGroup()
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
        .pickerViewerOverlay(viewerShown: $alertShownForExitGroup, title: "Exit Project !!") {
            VStack {
                LeftAlignedHStack(
                    Text("Are you sure you want to exit from this Project?")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        alertShownForExitGroup.toggle()
                    } label: {
                        Text("No")
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        alertShownForExitGroup.toggle()
                        exitGroup()
                    } label: {
                        Text("Yes")
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
    }
    
    var contentView: some View {
        ScrollView {
            VStack {
                WebUrlImage(url: viewModel.groupDetails?.groupImage.url,
                            placeholderImage: Image(IC.PLACEHOLDER.COMMON))
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .onTapGesture { showGroupImage.toggle() }
                
                LeftAlignedHStack(
                    Text(viewModel.groupDetails?.groupName ?? "")
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.semiBold(17.5))
                )
                .padding(.top, 19.5)
                
                LeftAlignedHStack(
                    Text("ID: " + (viewModel.groupDetails?.groupCode ?? ""))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.medium(13))
                )
                .padding(.top, 8)
                
                if let description = viewModel.groupDetails?.description {
                    LeftAlignedHStack(
                        Text(description)
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.light(12))
                    )
                    .padding(.top, 5)
                }
                
                groupMembersView
                
                if userType == .appAdmin, viewModel.groupDetails?.isAdmin == true {
                    // App Admin who is also Group Admin → show both Handover + Delete
                    VStack(spacing: 21) {
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFHandOverSuperAdminRightsContentView(
                                    groupDetails: viewModel.groupData,
                                    password: $password,
                                    userId: $userId,
                                    userName: $userName
                                )
                                .localize()
                            }
                        } label: {
                            Text("handover_admin_rights".localizedString())
                                .foregroundColor(.white)
                                .font(.medium(16))
                                .frame(maxWidth: .infinity, minHeight: 45)
                        }
                        .background(Color.Blue.THEME)
                        .cornerRadius(22.5)

                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFDeleteGroupContentView(password: $password, isActive: $isActive)
                                    .localize()
                            }
                        } label: {
                            Text("delete_project".localizedString())
                                .foregroundColor(Color.Orange.PINK)
                                .font(.regular(16))
                        }
                    }
                    .padding(.vertical, 21)

                } else if userType == .appAdmin {
                    // App Admin only (not group admin) → show only Delete
                    VStack(spacing: 21) {
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFDeleteGroupContentView(password: $password, isActive: $isActive)
                                    .localize()
                            }
                        } label: {
                            Text("delete_project".localizedString())
                                .foregroundColor(Color.Orange.PINK)
                                .font(.regular(16))
                        }
                    }
                    .padding(.vertical, 21)

                } else if viewModel.groupDetails?.isAdmin == true {
                    // Regular Group Admin → only Handover
                    VStack(spacing: 21) {
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFHandOverSuperAdminRightsContentView(
                                    groupDetails: viewModel.groupData,
                                    password: $password,
                                    userId: $userId,
                                    userName: $userName
                                )
                                .localize()
                            }
                        } label: {
                            Text("handover_admin_rights".localizedString())
                                .foregroundColor(.white)
                                .font(.medium(16))
                                .frame(maxWidth: .infinity, minHeight: 45)
                        }
                        .background(Color.Blue.THEME)
                        .cornerRadius(22.5)
                    }
                    .padding(.vertical, 21)

                } else {
                    // Everyone else → only Exit
                    VStack {
                        Button {
                            alertShownForExitGroup.toggle()
                        } label: {
                            Text("exit_project".localizedString())
                                .foregroundColor(Color.Orange.PINK)
                                .font(.regular(16))
                        }
                    }
                    .padding(.vertical, 21)
                }


            }
            .padding(.horizontal, 27.5)
            .padding(.top, 17)
        }
    }
    
    var groupMembersView: some View {
        VStack {
            HStack {
                Text("project_members".localizedString())
                    .foregroundColor(Color.Grey.STEEL)
                    .font(.semiBold(12.5))
                
                Spacer()
                
                if userType == .appAdmin || viewModel.groupDetails?.isAdmin ?? false {
                    Button {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            NFInviteUserContentView(viewModel: .init(groupData: viewModel.groupData), isFromDashboard: false)
                                .localize()
                        }
                    } label: {
                        Image(IC.ACTIONS.ADD_PEOPLE)
                    }
                }
                
                Button {
                    isSearchFieldActive.toggle()
                } label: {
                    Image(IC.ACTIONS.SEARCH)
                        .foregroundColor(Color.Green.DARK_GREEN)
                }
                .padding(.leading, 2)
            }
            
            if isSearchFieldActive {
                SearchFieldInputView(
                    onEditingChanged: {},
                    onDone: {
                        closeKeyboard()
                    },
                    text: $searchText,
                    placeholder: "search_members_placeholder".localizedString(),
                    closeButtonActive: false
                )
                .padding(.top, 15)
            }
            
            VStack(spacing: 20) {
                ForEach(viewModel.searchGroupMembers, id: \.userId) { (memberDetails) in
                    ListItemView(memberDetails: memberDetails, viewModel: viewModel)
                }
            }
            .padding(.top, 22.5)
        }
    }
    
    
    
    func handOverSuperAdminRights() {
        viewModel.handOverSuperAdminRights(handOverTo: userId, password: password) { completed in
            if viewModel.isSuccess {
                viewModel.onRefresh()
            } else {
                alertForIncorrectPassword.toggle()
            }
        }
    }
    
    func deleteGroup() {
        viewModel.deleteGroup(password: password) { completed in
            if viewModel.isSuccess {
                NotificationCenter.default.post(name: .DELETE_GROUP, object: nil)
                viewControllerHolder?.dismiss(animated: true, completion: nil)
            } else {
                alertForIncorrectPassword.toggle()
            }
        }
    }
    
    func exitGroup() {
        viewModel.exitGroup { completed in
            NotificationCenter.default.post(name: .UPDATE_GROUP_LIST, object: nil)
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
}

struct NFGroupDetailsContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFGroupDetailsContentView(viewModel: .init(groupId: "", groupCode: ""))
    }
}

extension NFGroupDetailsContentView {
    struct ListItemView: View {
        @Environment(\.viewController) private var viewControllerHolder: UIViewController?
        let memberDetails: GroupMemberDetails
        var viewModel: NFGroupDetailsViewModel
        @State var isSelect: Bool = false
        @State private var userRole: UserRole = .none
        @State private var userRoleChanged: Bool = false
        var userType: UserType = UserManager.getLoginedUser()?.userType ?? .normalUser

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    WebUrlImage(url: memberDetails.image?.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                        .frame(width: 58.5, height: 58.5)
                        .cornerRadius(29.25)
                    
                    VStack(spacing: 5) {
                        HStack {
                            VStack {
                                LeftAlignedHStack(
                                    Text(memberDetails.name)
                                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                        .font(.medium(15))
                                )
                                
                                LeftAlignedHStack(
                                    Text(memberDetails.email)
                                        .foregroundColor(Color.Grey.SLATE)
                                        .font(.regular(12))
                                )
                            }
                            
                            Spacer()
                            
                            Button {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    GroupMemberProfileContentView(viewModel: .init(userId: memberDetails.userId))
                                        .localize()
                                }
                            } label: {
                                Text("view".localizedString())
                                    .foregroundColor(Color.white)
                                    .font(.regular(12))
                            }
                            .frame(width: 60, height: 30)
                            .background(Color.Blue.THEME)
                            .cornerRadius(15)
                        }
                        
                        LeftAlignedHStack(
                            VStack {
                                Text(memberDetails.role.description)
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.regular(12))
                                    .padding(.horizontal, 5)
                                    .frame(minHeight: 25)
                            }
                                .background(Color.white)
                            .overlay(Capsule().stroke(Color.Blue.THEME, lineWidth: 1))
                            .cornerRadius(12.5)
                        )
                    }
                    .padding(.leading, 19)
                }
                
                if isSelect {
                    HStack {
                        Button {
                            removeMemberFromGroup(userId: memberDetails.userId)
                        } label: {
                            Text("delete_from_list".localizedString())
                                .foregroundColor(Color.Orange.PINK)
                                .font(.regular(12))
                                .frame(maxWidth: .infinity, minHeight: 30)
                        }
                        .background(Color.Pink.LIGHT)
                        .cornerRadius(4)
                        
                        Spacer ()
                        
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                RoleChangeContentView(memberDetails: memberDetails, userRole: $userRole, userRoleChanged: $userRoleChanged)
                                    .localize()
                            }
                        } label: {
                            Text("change_role".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                                .frame(maxWidth: .infinity, minHeight: 30)
                        }
                        .background(Color.Blue.PALE_GREY)
                        .cornerRadius(4)
                    }
                    .padding(.top, 12.5)
                }
                
                Divider()
                    .background(Color.Blue.VERY_LIGHT)
                    .frame(height: 0.5)
                    .padding([.top, .bottom], 12.5)
            }
            .onAppear {
                self.userRole = memberDetails.role
            }
            .onTapGesture {
                if userType == .appAdmin {
                    isSelect.toggle()
                }
            }
            .onChange(of: userRoleChanged) { (value) in
                viewModel.changeUserRole(userId: memberDetails.userId, newUserRole: userRole) { completed in
                    viewModel.onRefresh()
                }
                isSelect.toggle()
            }
        }
        
        func removeMemberFromGroup(userId: Int) {
            viewModel.removeMemberFromGroup(userId: userId) { completed in
                viewModel.onRefresh()
            }
        }
        
        
    }
}


extension View {
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.10)
                            .ignoresSafeArea()

                        LoadingIndicator(
                            animation: .threeBalls,
                            color: Color.Blue.THEME,
                            size: .medium,
                            speed: .normal
                        )
                    }
                }
            }
        )
    }
}
