//
//  HandOverSuperAdmniRightsContentView.swift
// QualityExpertise
//
//  Created by developer on 22/02/22.
//

import SwiftUI

struct HandOverSuperAdmniRightsContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var userDetails: UserData?
    @State var groupDetails = GroupData.dummy()
    @State var isUserSelect: Bool = false
    @State var userData: UserData?
    @Binding var password: String
    @Binding var userId: Int
    @Binding var userName: String
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }
            
            VStack {
                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            onClose()
                        } label: {
                            Image(IC.ACTIONS.CLOSE)
                        }
                    }
                    
                    LeftAlignedHStack(
                        Text("handover_super_admin_rights".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(17.5))
                    )
                    .padding(.top, 1.5)
                    
                    LeftAlignedHStack(
                        Text("handover_admin_message".localizedString())
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.light(12))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    )
                    .padding(.top, 21)
                    
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
                                        Text("remove".localizedString())
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
                            
                            VStack(spacing: 20) {
                                LeftAlignedHStack(
                                    Text("enter_your_password".localizedString())
                                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                        .font(.light(12))
                                )
                                
                                VStack {
                                    UIKitPasswordField(
                                        text: $password,
                                        placeholder: "password".localizedString(),
                                        isSecure: true,
                                        font: .regular(size: 12),
                                        textColor: UIColor(Color.Indigo.DARK),
                                        placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                                        isRTL: LocalizationService.shared.language.isRTLLanguage
                                    )
                                        .foregroundColor(Color.Indigo.DARK)
                                        .font(.regular(15))
                                        .frame(maxWidth: .infinity, minHeight: 45)
                                        .multilineTextAlignment(.center)
                                }
                                .overlay(Capsule().stroke(Color.Blue.PALE_GREY, lineWidth: 1))
                                .cornerRadius(22.5)
                                
                                Button {
                                    userId = userData?.userId ?? -1
                                    userName = userData?.name ?? ""
                                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                                } label: {
                                    Text("continue".localizedString())
                                        .foregroundColor(Color.white)
                                        .font(.medium(16))
                                        .frame(maxWidth: .infinity, minHeight: 45)
                                }
                                .background(Color.Blue.THEME)
                                .cornerRadius(22.5)
                            }
                        }
                    } else {
                        VStack {
                            Button {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    UserListContentView(viewModel: .init(groupData: groupDetails), isFromSelectAUser: true, isFromViewGroup: true, isUserActive: $isUserSelect, isUserActiveForNotification: .constant(false), userData: $userData, userDatas: .constant([UserData.dummy()]), forAvoidUser: true)
                                        .localize()
                                }
                            } label: {
                                Text("select_user".localizedString())
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.medium(15))
                                    .frame(maxWidth: .infinity, minHeight: 53)
                            }
                        }
                        .background(Color.Blue.PALE_GREY)
                        .cornerRadius(10)
                    }
                }
                .padding(.vertical, 41)
                .padding(.horizontal, 27.5)
                .background(Color.white)
                .cornerRadius([.topLeft, .topRight], 25)
            }
        }
        .listenToAppNotificationClicks()
    }
    
    private func onClose() {
        viewControllerHolder?.dismiss(animated: true, completion: nil)
    }
}
