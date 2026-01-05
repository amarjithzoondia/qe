//
//  GroupRequestRejectedPopUpContentView.swift
// QualityExpertise
//
//  Created by developer on 17/03/22.
//

import SwiftUI

struct GroupRequestRejectedPopUpContentView: View {
    @StateObject var viewModel: GroupRequestRejectedPopUpViewModel
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            viewControllerHolder?.dismiss(animated: true, completion: nil)
                        }, label: {
                            Image(IC.ACTIONS.CLOSE)
                                .padding(.trailing, 15)
                        })
                    }
                    
                    VStack(spacing: 20) {
                        LeftAlignedHStack(
                            Text(viewModel.notification.title ?? "")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.semiBold(15))
                        )
                        
                        LeftAlignedHStack(
                            Text(viewModel.notification.description ?? "")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.regular(12))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                        )
                    
                        VStack {
                            HStack(spacing: 10) {
                                WebUrlImage(url: viewModel.groupDetail?.groupImage.url)
                                    .frame(width: 44.5, height: 44.5)
                                    .cornerRadius(22.25)
                                
                                VStack(spacing: 5) {
                                    LeftAlignedHStack(
                                        Text(viewModel.groupDetail?.groupName ?? "")
                                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                            .font(.medium(14))
                                    )
                                    
                                    LeftAlignedHStack(
                                        Text(viewModel.groupDetail?.groupCode ?? "")
                                            .foregroundColor(Color.Grey.SLATE)
                                            .font(.regular(13))
                                    )
                                }
                                .padding(.leading, 19)
                                
                                Spacer()
                            }
                            .padding(.all, 17)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 25)
                .padding(.horizontal, 27)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                
                Spacer()
            }
            .padding(.horizontal, 27)
        }
        .onAppear {
            viewModel.viewGroup()
        }
    }
}

