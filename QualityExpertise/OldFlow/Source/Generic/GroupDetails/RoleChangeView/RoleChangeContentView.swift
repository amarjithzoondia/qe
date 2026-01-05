//
//  RoleChangeContentView.swift
// ALNASR
//
//  Created by developer on 22/02/22.
//

import SwiftUI

struct RoleChangeContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var memberDetails: GroupMemberDetails?
    @Binding var userRole: UserRole
    @Binding var userRoleChanged: Bool
    
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
                    HStack(spacing: 15.5) {
                        WebUrlImage(url: memberDetails?.image?.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                            .frame(width: 58.5, height: 58.5)
                            .cornerRadius(29.25)
                        
                        VStack(spacing: 8) {
                            LeftAlignedHStack(
                                Text(memberDetails?.name ?? "")
                                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                    .font(.medium(15))
                            )
                            
                            LeftAlignedHStack(
                                Text(memberDetails?.email ?? "")
                                    .foregroundColor(Color.Grey.SLATE)
                                    .font(.regular(12))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 15)
                    .padding(.horizontal, 32.5)
                    
                    VStack(spacing: 15.5) {
                        LeftAlignedHStack(
                            Text("SELECT ROLE")
                                .foregroundColor(Color.Grey.LIGHT_GREY_BLUE)
                                .font(.medium(12))
                        )
                        
                        HStack(spacing: 10) {
                            Button {
                                userRole = .admin
                            } label: {
                                HStack {
                                    Image(userRole == .admin ? IC.ACTIONS.RADIO_BUTTON.ON : IC.ACTIONS.RADIO_BUTTON.OFF)
                                    
                                    Text("Admin")
                                        .font(.regular(12))
                                        .foregroundColor(Color.Indigo.DARK)
                                }
                            }
                            
                            Button {
                                userRole = .participant
                            } label: {
                                HStack {
                                    Image(userRole == .participant ? IC.ACTIONS.RADIO_BUTTON.ON : IC.ACTIONS.RADIO_BUTTON.OFF)

                                    Text("Participant")
                                        .font(.regular(12))
                                        .foregroundColor(Color.Indigo.DARK)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 32.5)
                    }
                    .padding(.leading, (32.5 + 58.5 + 15.5) )
                    .padding(.trailing, 32.5)
                    
                    VStack {
                        HStack {
                            Button {
                                onClose()
                            } label: {
                                Text("Close")
                                    .foregroundColor(Color.Grey.SLATE)
                                    .font(.regular(16.2))
                                    .frame(maxWidth: .infinity, minHeight: 85)
                            }
                            
                            Divider()
                                .frame(width: 1, height: 37, alignment: .center)
                                .foregroundColor(Color.Silver.TWO)
                            
                            Button {
                                userRoleChanged.toggle()
                                onClose()
                            } label: {
                                Text("Apply")
                                    .foregroundColor(Color.Grey.SLATE)
                                    .font(.regular(16.2))
                                    .frame(maxWidth: .infinity, minHeight: 85)
                            }
                        }
                    }
                    .background(Color.white)
                    .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                }
                .background(Color.white)
                .cornerRadius(25, corners: [.topLeft, .topRight])
            }
        }
        .listenToAppNotificationClicks()
    }
    
    private func onClose() {
        viewControllerHolder?.dismiss(animated: true, completion: nil)
    }
}
