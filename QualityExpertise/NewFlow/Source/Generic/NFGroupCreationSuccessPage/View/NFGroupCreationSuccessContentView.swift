//
//  NFGroupCreationSuccessContentView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import MobileCoreServices

struct NFGroupCreationSuccessContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var viewModel: GroupCreationSuccessViewModel
    @State private var showShareSheet: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack{
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        Image(IC.LOGO.SUCCESS)
                            .padding(.top, 26.5)
                        
                        Text(viewModel.titleString)
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(19.2))
                            .multilineTextAlignment(.center)
                            .padding(.top, 32.5)
                        
                        VStack {
                            HStack {
                                WebUrlImage(url: viewModel.groupDetails.groupImage.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                                    .frame(width: 57, height: 57)
                                    .cornerRadius(28.5)
                                    .padding(.leading, 22)
                                    .padding(.vertical, 23)
                                
                                VStack {
                                    LeftAlignedHStack(
                                        Text(viewModel.groupDetails.groupName)
                                            .foregroundColor(Color.Indigo.DARK)
                                            .font(.medium(14))
                                    )
                                    
                                    LeftAlignedHStack(
                                        Text(viewModel.groupDetails.groupCode)
                                            .foregroundColor(Color.Grey.SLATE)
                                            .font(.regular(12))
                                    )
                                        .padding(.top, 3)
                                }
                                .padding(.leading, 25)
                                
                                Spacer()
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                            
                            
                            VStack(spacing: 13.5) {
                                Text("your_code_is".localizedString())
                                    .foregroundColor(Color.Grey.DARK_BLUE)
                                    .font(.regular(14.5))
                                    .padding(.top, 10)
                                
                                Text(viewModel.groupDetails.groupCode)
                                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                    .font(.semiBold(22))
                                
                                
                                Button(action: {
                                    UIPasteboard.general.string = viewModel.groupDetails.groupCode
                                }) {
                                    Text("copy_this_code".localizedString())
                                        .foregroundColor(Color.Blue.THEME)
                                        .font(.light(12))
                                        .underline(color: Color.Blue.THEME)
                                }
                                .padding(.bottom, 18)
                            }
                        }
                        .background(Color.Grey.PALE_THREE)
                        .cornerRadius(10)
                        .padding(.top, 23.5)
                        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                        
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                NFInviteUserContentView(viewModel: .init(groupData: viewModel.groupDetails), isFromDashboard: false)
                                    .localize()
                            }
                        } label: {
                            Text("invite_users_to_project".localizedString())
                                .foregroundColor(.white)
                                .font(.medium(16))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.Blue.THEME)
                        .cornerRadius(27.5)
                        .padding(.top, 23.5)
                    }
                    .padding(.horizontal, 46.5)
                    .padding(.bottom, 20)
                }
            }
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: .CLOSE_BOOKING_FLOW, object: nil)
                })
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showShareSheet = true
                    }, label: {
                        Image(IC.ACTIONS.SHARE)
                    })
                }
            }
            .sheet(isPresented: $showShareSheet) {
                let message = String(
                    format: "share_message_project".localizedString(),
                    viewModel.groupDetails.groupName,
                    viewModel.groupDetails.groupCode
                )
                ShareSheet(activityItems: [message])
            }
            .listenToAppNotificationClicks()
        }
    }
}

struct NFGroupCreationSuccessContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFGroupCreationSuccessContentView(viewModel: .init(groupdetails: GroupData.dummy()))
    }
}
