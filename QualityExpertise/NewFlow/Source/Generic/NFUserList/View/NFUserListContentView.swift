//
//  NFUserListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 11/06/25.
//

import SwiftUI

import SwiftUI
import SwiftfulLoadingIndicators
import SwiftUIX
import simd

struct NFUserListContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: NFUserListViewModel
    @State var searchText = ""
    @State var isFromSelectAUser = false
    @State var isAllGroupMembersSelected = false
    @State var isFromViewGroup = false
    @State var isFromCreateObservation = false
    @Binding var isUserActive: Bool
    @Binding var isUserActiveForNotification: Bool
    @Binding var userData: UserData?
    @Binding var userDatas: [UserData]?
    @State var customResponsiblePersonName = ""
    @State var customResponsiblePersonEmail = ""
    @State var isCustomResponsiblePersonSelected = false
    @State var closeButtonActive = false
    @State var forAvoidUser = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    SearchFieldInputView(
                        onEditingChanged: {},
                        onDone: {
                            closeKeyboard()
                        },
                        text: $searchText,
                        placeholder: "Search User".localizedString(),
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
                        if viewModel.isLoading {
                            LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                        } else if viewModel.noDataFound {
                            "No User found".localizedString().viewRetry {
                                viewModel.onRetry()
                            }
                        } else if let error = viewModel.error {
                            error.viewRetry(isError: true) {
                                viewModel.onRetry()
                            }
                        } else {
//                            if viewModel.searchUsersList.count == 1 && forAvoidUser {
                                if viewModel.searchUsersList.first?.userId == UserManager().user?.userId {
                                    "No User found".localizedString().viewRetry {
                                        viewModel.onRetry()
                                    }
                                }
                             else {
                                ScrollView(showsIndicators: false) {
                                    if isFromSelectAUser && !isFromViewGroup {
                                        VStack(spacing: 20) {
                                            Button{
                                                isAllGroupMembersSelected.toggle()
                                                if isAllGroupMembersSelected {
                                                    viewModel.searchUsersList.indices.forEach({viewModel.searchUsersList[$0].isSelected = false})
                                                    isCustomResponsiblePersonSelected = false
                                                }
                                            } label: {
                                                VStack(spacing: 0) {
                                                    HStack(spacing: 10) {
                                                        Text("Not Specified")
                                                            .foregroundColor(Color.Indigo.DARK)
                                                            .font(.medium(15))
                                                            .padding(.leading, 15)
                                                        
                                                        Spacer()
                                                        
                                                        Image(isAllGroupMembersSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                                                            .renderingMode(.original)
                                                            .frame(width: 18.0, height: 18.0)
                                                            .padding(.trailing, 15)
                                                    }
                                                    .frame(height: 45)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12.5)
                                                            .stroke(Color.Indigo.DUSK_FOUR_15, lineWidth: 1.0)
                                                    )
                                                }
                                            }
                                            
                                            VStack(spacing: 15) {
                                                VStack {
                                                    HStack{
                                                        Text("Custom Entry")
                                                            .foregroundColor(Color.Indigo.DARK)
                                                            .font(.medium(15))
                                                        
                                                        Spacer()
                                                        
                                                        Button {
                                                            isCustomResponsiblePersonSelected.toggle()
                                                            if isCustomResponsiblePersonSelected {
                                                                viewModel.searchUsersList.indices.forEach({viewModel.searchUsersList[$0].isSelected = false})
                                                                isAllGroupMembersSelected = false
                                                            }
                                                        } label: {
                                                            
                                                            Image(isCustomResponsiblePersonSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                                                                .renderingMode(.original)
                                                                .frame(width: 18.0, height: 18.0)
                                                        }
                                                    }
                                                    
                                                    if isCustomResponsiblePersonSelected {
                                                        VStack {
                                                            customResponsiblePersonNameView
                                                            
                                                            customResponsiblePersonEmailView
                                                        }
                                                        
                                                    }
                                                }
                                                .padding(.all, 15)
                                            }
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.Indigo.DUSK_FOUR_15, lineWidth: 1.0)
                                            )
                                        }
                                    }
                                    
                                    LeftAlignedHStack(
                                        Text("USER LIST")
                                            .foregroundColor(Color.Grey.STEEL)
                                            .font(.semiBold(12.5))
                                    )
                                    .padding(.top, 20)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(viewModel.searchUsersList, id: \.userId) { user in
                                            if forAvoidUser {
                                                if user.userId != UserManager().user?.userId {
                                                    ListItemView(userData: user, viewModel: viewModel, isSelected: .constant(user.isSelected ?? false), isFromSelectUser: isFromSelectAUser, isAllGroupMembersSelected: $isAllGroupMembersSelected, isCustomResponsiblePersonSelected: $isCustomResponsiblePersonSelected, customResponsiblePersonEmail: $customResponsiblePersonEmail, customResponsiblePersonName: $customResponsiblePersonName)
                                                }
                                            } else {
                                                ListItemView(userData: user, viewModel: viewModel, isSelected: .constant(user.isSelected ?? false), isFromSelectUser: isFromSelectAUser, isAllGroupMembersSelected: $isAllGroupMembersSelected, isCustomResponsiblePersonSelected: $isCustomResponsiblePersonSelected, customResponsiblePersonEmail: $customResponsiblePersonEmail, customResponsiblePersonName: $customResponsiblePersonName)
                                            }
                                        }
                                    }
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                                }
                            }
                        }
                    }
                    .padding(.top, 34.5)
                    
                    Spacer()
                }
                .padding(.top, 21.5)
                .padding(.bottom, 20)
                .padding(.horizontal, 28)
            }
            .navigationBarTitle("User".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isFromSelectAUser {
                            if isAllGroupMembersSelected {
                                self.userData = UserData(userId: -2, image: "", name: "", email: "", role: Optional.none, isSelected: false)
                                self.isUserActive = true
                                
                            } else if isCustomResponsiblePersonSelected {
                                self.isUserActive = true
                            } else {
                                if viewModel.userData != nil {
                                    userData = viewModel.userData
                                    self.isUserActive = true
                                } else {
                                    self.isUserActive = false
                                }
                            }
                            
                            if (userData == nil || viewModel.searchUsersList.allSatisfy({$0.isSelected == false})) && !isAllGroupMembersSelected && customResponsiblePersonName == "" {
                                viewModel.toast = SystemError("Please select atleast one user.").toast
                            } else if customResponsiblePersonEmail != "" && !customResponsiblePersonEmail.isValidEmail() {
                                customResponsiblePersonEmail = ""
                                viewModel.toast = SystemError("Enter a valid mail").toast
                            } else {
                                if isCustomResponsiblePersonSelected {
                                    self.userData = UserData(userId: -3, image: "", name: customResponsiblePersonName, email: customResponsiblePersonEmail, role: Optional.none, isSelected: false)
                                    self.isUserActive = true
                                }
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            }
                            
                        } else {
                            if let selectedUsers = viewModel.selectedUsers {
                                userDatas = selectedUsers
                                self.isUserActiveForNotification = true
                            }
                            
                            if userDatas == nil || viewModel.searchUsersList.allSatisfy({$0.isSelected == false}) {
                                viewModel.toast = SystemError("Please select atleast one user.").toast
                            } else {
                                viewControllerHolder?.dismiss(animated: true, completion: nil)
                            }
                        }
                        
                        
                    }, label: {
                        Text("Apply")
                            .foregroundColor(Color.Blue.THEME)
                            .font(.regular(15))
                    })
                }
            }
            .onAppear {
                if userData?.userId == -2 {
                    isAllGroupMembersSelected = true
                } else if userData?.userId == -3 {
                    isCustomResponsiblePersonSelected = true
                    customResponsiblePersonName = userData?.name ?? ""
                    customResponsiblePersonEmail = userData?.email ?? ""
                }
                let selectedUserIds = userDatas?.map({$0.userId})
                viewModel.fetchList(selectedUserId: userData?.userId, isFromSelectAUser: isFromSelectAUser, selectedUserIds: selectedUserIds)
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
    }
    
    var customResponsiblePersonNameView: some View {
        ThemeTextEditorView(
            text: $customResponsiblePersonName,
            title: "".localizedString(),
            placeholder: "Responsible Person Name".localizedString(), disabled: isCustomResponsiblePersonSelected ? false : true,
            isMandatoryField: isCustomResponsiblePersonSelected ? true : false,
            limit: Constants.Number.Limit.Observation.REPORTED_BY,
        )
    }
    
    var customResponsiblePersonEmailView: some View {
        ThemeTextEditorView(
            text: $customResponsiblePersonEmail,
            title: "".localizedString(),
            placeholder: "Email Address(optional)".localizedString(),
            disabled: isCustomResponsiblePersonSelected ? false : true,
            isMandatoryField: false,
            limit: Constants.Number.Limit.Observation.REPORTED_BY
        )
    }
    
}

extension NFUserListContentView {
    struct ListItemView: View {
        let userData: UserData
        var viewModel: NFUserListViewModel
        @Binding var isSelected: Bool
        var isFromSelectUser: Bool
        @Binding var isAllGroupMembersSelected: Bool
        @Binding var isCustomResponsiblePersonSelected: Bool
        @Binding var customResponsiblePersonEmail: String
        @Binding var customResponsiblePersonName: String
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    WebUrlImage(url: userData.image.url)
                        .frame(width: 58.5, height: 58.5)
                        .cornerRadius(29.25)
                    
                    VStack(spacing: 5) {
                        LeftAlignedHStack(
                            Text(userData.name)
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(14))
                        )
                        
                        LeftAlignedHStack(
                            Text(userData.email)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                        )
                        
                        LeftAlignedHStack(
                            Text(userData.role?.description ?? "")
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                                .padding(.horizontal, 5)
                                .frame(minHeight: 25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12.5)
                                        .stroke(Color.Blue.THEME, lineWidth: 0.5)
                                )
                        )
                    }
                    .padding(.leading, 19)
                    
                    Spacer()
                    
                    Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                        .renderingMode(.original)
                        .frame(width: 18.0, height: 18.0)
                        .padding(.trailing, 5)
                }
                
                Divider()
                    .background(Color.Blue.VERY_LIGHT)
                    .frame(height: 0.5)
                    .padding([.top, .bottom], 12.5)
            }
            .onTapGesture {
                viewModel.register(userData: userData, isSelected: !isSelected, isFromSelectuser: isFromSelectUser)
                isSelected.toggle()
                isAllGroupMembersSelected = false
                isCustomResponsiblePersonSelected = false
                customResponsiblePersonEmail = ""
                customResponsiblePersonName = ""
            }
        }
    }

}

struct NFUserListContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFUserListContentView(viewModel: .init(groupData: GroupData.dummy()), isUserActive: .constant(false), isUserActiveForNotification: .constant(false), userData: .constant(UserData.dummy()), userDatas: .constant([UserData.dummy()]))
    }
}
