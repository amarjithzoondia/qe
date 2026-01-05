//
//  NFDeleteGroupContentView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI

struct NFDeleteGroupContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Binding var password: String
    @Binding var isActive: Bool
    
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
                        LeftAlignedHStack(
                            Text("Project Delete")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.semiBold(17.5))
                        )
                        
                        Spacer()
                        
                        Button {
                            onClose()
                        } label: {
                            Image(IC.ACTIONS.CLOSE)
                        }
                    }
                    
                    LeftAlignedHStack(
                        Text("Are you sure want to go ahead with this? If you continue, the trasaction is irreversible.")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.light(12))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    )
                    .padding(.top, 21)
                    
                    VStack(spacing: 20) {
                        LeftAlignedHStack(
                            Text("Enter Your Password")
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
                            isActive.toggle()
                            viewControllerHolder?.dismiss(animated: true, completion: nil)
                        } label: {
                            Text("Continue")
                                .foregroundColor(Color.white)
                                .font(.medium(16))
                                .frame(maxWidth: .infinity, minHeight: 45)
                        }
                        .background(Color.Blue.THEME)
                        .cornerRadius(22.5)
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
