//
//  InviteUserContentView.swift
// ALNASR
//
//  Created by developer on 27/01/22.
//

import SwiftUI
import CoreMIDI

struct InviteUserContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: InviteUserViewModel
    @State private var userEmailList: [String] = []
    @State var isFromDashboard: Bool = false
    @State var email: String = Constants.EMPTY_STRING
    @State private var alertShown: Bool = false
    @State private var userInviteActive: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        VStack(spacing: 18) {
                            LeftAlignedHStack(
                                Text("Add User")
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.semiBold(14.5))
                            )
                            
                            
                            LeftAlignedHStack(
                                Text("You can invite users to your group by entering their email ID")
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.regular(12))
                            )
                            
                            HStack(spacing: 0) {
                                Image(IC.PLACEHOLDER.EMAIL)
                                    .padding(.leading, 14)
                                
                                TextField(Constants.EMPTY_STRING, text: $email)
                                    .keyboardType(.asciiCapable)
                                    .font(.regular(12))
                                    .lineLimit(1)
                                    .modifier(TextFieldInputViewStyle(placeholder: "Email Address", foregroundColor: Color.Indigo.DARK, text: $email))
                                    .autocapitalization(.none)
                                    .padding(.leading, 7.5)
                                
                                Spacer()
                                
                                Button {
                                    addEmailToList()
                                } label: {
                                    Text("Add")
                                        .foregroundColor(Color.Blue.THEME)
                                        .font(.semiBold(12))
                                }
                                .padding(.trailing, 14)
                            }
                            .background(Color.Grey.PALE)
                            .frame(height: 38)
                            .cornerRadius(19)
                            .shadow(color: Color.Black.BLACK_2, radius: 5, x: 1, y: 1)
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 33)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                    .padding(.horizontal, 28)
                    .padding(.top, 25)
                    
                    if !userEmailList.isEmpty {
                        VStack {
                            LeftAlignedHStack(
                                Text("ADDED PEOPLE LIST")
                                    .foregroundColor(Color.Grey.STEEL)
                                    .font(.semiBold(12.5))
                            )
                            
                            ScrollView {
                                ForEach(self.userEmailList.indices, id: \.self) { index in
                                    VStack {
                                        HStack {
                                            Text(userEmailList[index])
                                                .foregroundColor(Color.Indigo.DARK)
                                                .font(.regular(12))
                                            
                                            Spacer()
                                            
                                            Button {
                                                userEmailList.remove(at: index)
                                            } label: {
                                                Image(IC.ACTIONS.MINUS)
                                            }
                                        }
                                        
                                        Divider()
                                            .frame(height: 1)
                                            .foregroundColor(Color.Silver.TWO)
                                            .padding(.top, 8)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.top, 11.5)
                        }
                        .padding(.top, 45)
                        .padding(.horizontal, 28)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 25 + 41)
                
                
                VStack {
                    
                    Spacer()
                    
                    Button {
                        guard userEmailList.count > 0 else {
                            viewModel.toast = Toast.alert(title: "Alert!", subTitle: "Pleae enter atleast one email address.", displayMode: .banner(.slide), isSuccess: false)
                            return viewModel.showToast = true
                        }

                        
                        if isFromDashboard {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                GroupListContentView(isFromViewGroup: false, isActive: $userInviteActive, groupData: $viewModel.groupData)
                            }
                        } else {
                            userInviteActive.toggle()
                        }
                    } label: {
                        if isFromDashboard {
                            Text("Select Group")
                                .foregroundColor(Color.white)
                                .font(.medium(16))
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                        } else {
                            Text("Invite")
                                .foregroundColor(Color.white)
                                .font(.medium(16))
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                        }
                    }
                    .background(Color.Blue.THEME)
                    .cornerRadius(22.5)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 28)
                
            }
            .navigationBarTitle("Invite", displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .onChange(of: userInviteActive, perform: { value in
                inviteUser()
            })
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: $alertShown, title: "Invitations sent!!".localizedString()) {
            
            VStack {
                LeftAlignedHStack(
                    Text("Group invitations successfully sent to given emails.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(12))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("Ok")
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
    }
    
    func addEmailToList() {
        guard email != "" else {
            viewModel.toast = Toast.alert(title: "Alert!", subTitle: "Pleae enter email address.", displayMode: .banner(.slide), isSuccess: false)
            return viewModel.showToast = true
        }
        
        guard email.isValidEmail() else {
            viewModel.toast = Toast.alert(title: "Alert!", subTitle: "Pleae enter a valid email address.", displayMode: .banner(.slide), isSuccess: false)
            return viewModel.showToast = true
        }
        
        if !userEmailList.contains(email) {
            userEmailList.append(email)
            email = ""
        } else {
            viewModel.showToast = true
        }
    }
    
    func inviteUser() {
        viewModel.inviteUser(userEmailList: userEmailList) { (completed) in
            alertShown = true
        }
    }
}

struct InviteUserContentView_Previews: PreviewProvider {
    static var previews: some View {
        InviteUserContentView(viewModel: .init(groupData: GroupData.dummy()))
    }
}
