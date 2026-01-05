//
//  GroupMemberProfileContentView.swift
// ALNASR
//
//  Created by developer on 22/02/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct GroupMemberProfileContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: GroupMemberProfileViewModel
    @State private var showProfileImage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    if viewModel.noDataFound {
                        "no_members_found".localizedString()
                            .viewRetry {
                            viewModel.onRetry()
                        }
                    } else if let error = viewModel.error {
                        error.viewRetry(isError: true) {
                            viewModel.onRetry()
                        }
                    } else {
                        ScrollView {
                            VStack {
                                profileDetailView
                            }
                            .padding(.top, 36.5)
                            .padding(.horizontal, 35)
                        }
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
            .imageViewerOverlay(viewerShown: $showProfileImage, images: [viewModel.member?.profileImage ?? ""])
            .navigationBarTitle("profile".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .onAppear(perform: viewModel.fetchMemberDetail)
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
    }
    
    var profileDetailView: some View {
        VStack(spacing: 14) {
            WebUrlImage(url: viewModel.member?.profileImage?.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                .frame(width: 86, height: 86, alignment: .center)
                .cornerRadius(43)
                .onTapGesture {
                    if viewModel.member?.profileImage != "" {
                        showProfileImage.toggle()
                    }
                }
            
            VStack(spacing: 15) {
                LeftAlignedHStack(
                    Text("full_name".localizedString())
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.regular(12))
                )
                
                LeftAlignedHStack(
                    Text(viewModel.member?.name ?? "")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(15))
                )
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
            
            VStack(spacing: 15) {
                LeftAlignedHStack(
                    Text("email".localizedString())
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.regular(12))
                )
                
                LeftAlignedHStack(
                    Text(viewModel.member?.email ?? "")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(15))
                )
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
            
            VStack(spacing: 15) {
                LeftAlignedHStack(
                    Text("designation".localizedString())
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.regular(12))
                )
                
                LeftAlignedHStack(
                    Text(viewModel.member?.designation ?? "NA")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(15))
                )
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
            
            VStack(spacing: 15) {
                LeftAlignedHStack(
                    Text("company_name".localizedString())
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.regular(12))
                )
                
                LeftAlignedHStack(
                    Text(viewModel.member?.company ?? "na".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(15))
                )
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
        }
    }
}

struct GroupMemberProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        GroupMemberProfileContentView(viewModel: .init(userId: -1))
    }
}
