//
//  ResponsiblePersonChangeContentView.swift
// ALNASR
//
//  Created by developer on 02/03/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ResponsiblePersonChangeContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: ResponsiblePersonChangeViewModel
    @State var description = Constants.EMPTY_STRING
    @State var userData: UserData?
    @State var isUserSelect: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.35)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    HStack {
                        LeftAlignedHStack(
                            Text("Open Observation")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.semiBold(17.5))
                        )
                        
                        Spacer()
                        
                        Button {
                            onClose()
                        } label: {
                            Text("Back")
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        }
                    }
                    
                    LeftAlignedHStack(
                        Text("Request Observation Responsible Person Change")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(14))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    )
                    
                    LeftAlignedHStack(
                        Text("New Responsible Person")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(12))
                    )
                    
                    if isUserSelect {
                        VStack {
                            VStack {
                                HStack {
                                    WebUrlImage(url: userData?.image.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                                        .frame(width: 45.5, height: 45.5)
                                        .cornerRadius(22.25)
                                    
                                    VStack(spacing: 10) {
                                        LeftAlignedHStack(
                                            Text(userData?.name ?? "")
                                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                                .font(.medium(15))
                                        )
                                        
                                        LeftAlignedHStack(
                                            Text(userData?.email ?? "")
                                                .foregroundColor(Color.Grey.SLATE)
                                                .font(.regular(12))
                                        )
                                    }
                                    .padding(.leading, 12.5)
                                    
                                    Spacer()
                                    
                                    Button {
                                        isUserSelect.toggle()
                                    } label: {
                                        Text("Remove")
                                            .foregroundColor(Color.Blue.THEME)
                                            .font(.regular(12))
                                    }

                                }
                                .padding(.vertical, 19)
                                .padding(.horizontal, 16)
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                        }
                    } else {
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                UserListContentView(viewModel: .init(groupData: viewModel.groupData), isFromSelectAUser: true, isFromViewGroup: true, isUserActive: $isUserSelect, isUserActiveForNotification: .constant(false), userData: $userData, userDatas: .constant([UserData.dummy()]))
                            }
                        } label: {
                            Text("Select User")
                                .foregroundColor(Color.Blue.THEME)
                                .font(.medium(15))
                                .frame(width: screenWidth - (27.5 + 27.5 + 15 + 15), height: 53)
                        }
                        .background(Color.Blue.PALE_GREY)
                        .cornerRadius(10)
                    }
                    
                    LeftAlignedHStack(
                        Text("Provide a short description of why you want to change Responsible Person of this observation.")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.regular(12))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    )
                    
                    VStack(spacing: 0) {
                        LeftAlignedHStack(
                            Text("DESCRIPTION")
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(12))
                        )
                        
                        LeftAlignedHStack(
                            TextField(text: $description)
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.medium(12))
                                .modifier(TextFieldInputViewStyle(placeholder: "Description", foregroundColor: Color.Grey.LIGHT_GREY_BLUE, text: $description))
                        )
                        .padding(.top, 10)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            changeResponsibility()
                        } label: {
                            Text("Continue")
                                .foregroundColor(Color.white)
                                .font(.regular(12))
                                .frame(width: 80, height: 35)
                        }
                        .background(Color.Blue.THEME)
                        .cornerRadius(17.5)
                    }
                }
                .padding(.vertical, 41)
                .padding(.horizontal, 27.5)
                .background(Color.white)
                .cornerRadius([.topLeft, .topRight], 25)
            }
            
            VStack {
                if viewModel.isLoading {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                }
            }
        }
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
        .listenToAppNotificationClicks()
    }
    
    private func onClose() {
        viewControllerHolder?.dismiss(animated: true, completion: nil)
    }
    
    func changeResponsibility() {
        viewModel.responsiblePersonChange(description: description, userId: userData?.userId ?? -1) { completed in
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
}
