//
//  TermsofUseContentView.swift
// ALNASR
//
//  Created by developer on 18/02/22.
//

import SwiftUI
import WebKit
import SwiftfulLoadingIndicators

struct TermsofUseContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = TermsOfUseViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                if let error = viewModel.error {
                    error.viewRetry {
                        viewModel.fetchDetails()
                    }
                } else {
                    VStack(spacing: 30) {
                        Image(IC.LOGO.ABOUT_US)
                        
                        HTMLStringView(htmlContent: viewModel.content)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .disabled(viewModel.isLoading)
                }
                
                VStack {
                    if viewModel.isLoading {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .navigationBarTitle("Terms of use", displayMode: .inline)
            .toolbar(content: {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            })
            .onAppear(perform: viewModel.fetchDetails)
            .listenToAppNotificationClicks()
        }
    }
}

struct TermsofUseContentView_Previews: PreviewProvider {
    static var previews: some View {
        TermsofUseContentView()
    }
}

