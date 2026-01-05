//
//  GroupDetailsContentView.swift
// QualityExpertise
//
//  Created by developer on 21/02/22.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX

struct GroupDetailsContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: GroupDetailsViewModel
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView {
                        VStack {
                            WebUrlImage(url: viewModel.groupDetails?.groupImage.url, placeholderImage: Image(IC.PLACEHOLDER.COMMON))
                                .scaledToFill()
                                .frame(height: 137, alignment: .center)
                                .cornerRadius(10)
                                .clipped()
                                .onTapGesture {
                                    showGroupImage.toggle()
                                }
                            
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
                            
                            if viewModel.groupDetails?.userRole == .superAdmin {
                                VStack(spacing: 21) {
                                    Button {
                                        viewControllerHolder?.present(style: .overCurrentContext) {
                                            HandOverSuperAdmniRightsContentView(groupDetails: viewModel.groupData, password: $password, userId: $userId, userName: $userName)
                                                .localize()
                                        }
                                    } label: {
                                        Text("handover_super_admin_rights".localizedString())
                                            .foregroundColor(Color.white)
                                            .font(.medium(16))
                                            .frame(maxWidth: .infinity, minHeight: 45)
                                    }
                                    .background(Color.Blue.THEME)
                                    .cornerRadius(22.5)
                                    
                                    Button {
                                        viewControllerHolder?.present(style: .overCurrentContext) {
                                            DeleteGroupContentView(password: $password, isActive: $isActive)
                                                .localize()
                                        }
                                    } label: {
                                        Text("delete_group".localizedString())
                                            .foregroundColor(Color.Orange.PINK)
                                            .font(.regular(16))
                                    }
                                }
                                .padding(.vertical, 21)
                            } else {
                                VStack {
                                    Button {
                                        alertShownForExitGroup.toggle()
                                    } label: {
                                        Text("exit_group".localizedString())
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
                if viewModel.isLoading {
                    Color.black
                        .opacity(0.10)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .navigationBarTitle("group".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.groupDetails?.userRole == .superAdmin {
                        HStack(spacing: 15) {
                            Button {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    CreateGroupContentView(viewModel: .init(isEditing: true, groupName: viewModel.groupDetails?.groupName ?? "", description: viewModel.groupDetails?.description ?? "", image: viewModel.groupDetails?.groupImage ?? "", groupCode: viewModel.groupDetails?.groupCode ?? ""))
                                        .localize()
                                }
                            } label: {
                                Image(IC.ACTIONS.EDIT_BLACK)
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
        .imageViewerOverlay(viewerShown: $showGroupImage, images: [viewModel.groupDetails?.groupImage ?? ""])
        .pickerViewerOverlay(viewerShown: $alertShownForHandOver, title: "confirm".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text(String(format: "handover_admin_rights_to_user".localizedString(), userName))
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
        .pickerViewerOverlay(viewerShown: $alertShownForDeleteGroup, title: "delete_group_title".localizedString()) {
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
        .pickerViewerOverlay(viewerShown: $alertShownForExitGroup, title: "exit_group_title".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("exit_group_warning".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        alertShownForExitGroup.toggle()
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
                        alertShownForExitGroup.toggle()
                        exitGroup()
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
    }
    
    var groupMembersView: some View {
        VStack {
            HStack {
                Text("group_members".localizedString())
                    .foregroundColor(Color.Grey.STEEL)
                    .font(.semiBold(12.5))
                
                Spacer()
                
                Button {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        InviteUserContentView(viewModel: .init(groupData: viewModel.groupData), isFromDashboard: false)
                            .localize()
                    }
                } label: {
                    Image(IC.ACTIONS.ADD_PEOPLE)
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

struct GroupDetailsContentView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetailsContentView(viewModel: .init(groupId: "", groupCode: ""))
    }
}

extension GroupDetailsContentView {
    struct ListItemView: View {
        @Environment(\.viewController) private var viewControllerHolder: UIViewController?
        let memberDetails: GroupMemberDetails
        var viewModel: GroupDetailsViewModel
        @State var isSelect: Bool = false
        @State private var userRole: UserRole = .none
        @State private var userRoleChanged: Bool = false

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
                if viewModel.groupDetails?.userRole == .superAdmin || viewModel.groupDetails?.userRole == .admin {
                    if memberDetails.role != .superAdmin {
                        isSelect.toggle()
                    }
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
