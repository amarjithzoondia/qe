//
//  SplashContentView.swift
// QualityExpertise
//
//  Created by developer on 18/01/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct SplashContentView: View {
    @StateObject var viewModel = SpalshViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    var isGuest: Bool? {
        UserManager.getCheckOutUser()?.isGuestUser
    }

    
    var body: some View {
        
        ZStack {
            Color.Blue.THEME
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Image(IC.LOGO.SPLASH_LOGO)
                
//                Image(IC.LOGO.SPLASH_REPORT)
//                    .padding(.top, 19.5)
//                
//                Image(IC.LOGO.SPLASH_ON_THE_GO)
//                    .padding(.top, 6.5)
                
                if viewModel.error != nil {
                    Button(action: {
                        refreshData()
                    }) {
                       Text("Retry")
                            .foregroundColor(.white)
                            .font(.semiBold(16))
                    }
                    .frame(width: 100, height: 50, alignment: .center)
                    .background(Color.clear)
                    .cornerRadius(25)
                    .padding(.top, 30)
                }
                
                if viewModel.isLoading {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                        .padding(.top, 30)
                }
            }
        }
        .onAppear(perform: onAppear)
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
    }
    
    private func onAppear() {
        refreshData()
    }
    
    private func refreshData() {
        viewModel.userCheckout { completed in
            viewControllerHolder?.present(style: .overCurrentContext) {
                if completed {
                    // ✅ User exists (online or offline)
                    if let guest = isGuest {
                        if guest {
                            HomeScreenView()
                                .localize()
                        } else {
                            CustomNFTabBarContentView()
                                .localize()
                        }
                    } else {
                        // fallback if somehow isGuest is nil
                        HomeScreenView()
                            .localize()
                    }
                } else {
                    HomeScreenView()
                        .localize()
                }
            }
        }
    }

}

struct SplashContentView_Previews: PreviewProvider {
    static var previews: some View {
        SplashContentView()
    }
}
