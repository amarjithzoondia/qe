//
//  DeletionSuccessView.swift
// ALNASR
//
//  Created by Developer on 21/07/22.
//

import SwiftUI

struct DeletionSuccessView: View {
    
    @Binding var deletionResponse: DeleteVerifyRequestResponse?
    
    var body: some View {
        if let deletionResponse = deletionResponse {
            ZStack(alignment: .center) {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack {
                        
                        Image(IC.LOGO.TRASH_CAN)
                            .frame(width: 174, height: 203, alignment: .center)
                        
                        Text(deletionResponse.title)
                            .font(.semiBold(20))
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color.Indigo.DARK)
                            .multilineTextAlignment(.center)
                            .padding(.top, 24.5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28.5)
                        
                        Text(deletionResponse.description)
                            .font(.light(12))
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color.Blue.BLUE_GREY)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 35.5)
                        
                        Button(action: {
                            goToLoginScreen()
                        }) {
                            Text("Continue")
                                .font(.medium(16))
                                .foregroundColor(.white)
                                .frame(height: 45)
                            .padding(.horizontal, 44)                    }
                        .background(Color.Blue.THEME)
                        .cornerRadius(45/2)
                        
                    }
                    .padding(.horizontal, 60)
                    .padding(.top, 120)
                }
            }
        } else {
            EmptyView()
        }
    }
    
    func goToLoginScreen() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        if let rootViewController = rootViewController {
            rootViewController.dismiss(animated: true, completion: {                NotificationCenter.default.post(name: .RELAUNCH_APP, object: nil)
            })
        } else {
            NotificationCenter.default.post(name: .RELAUNCH_APP, object: nil)
        }
    }
}


