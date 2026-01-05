//
//  AboutUsContentView.swift
// ALNASR
//
//  Created by developer on 09/02/22.
//

import SwiftUI

struct AboutUsContentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = AboutUsViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                if let error = viewModel.error {
                    error.viewRetry(isError: true) {
                        viewModel.fetchDetails()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            Image(IC.LOGO.ABOUT_US)
                                .frame(width: 204.5, height: 179.5, alignment: .center)
                                .padding(.top, 13)
                            
                            LeftAlignedHStack(
                                Text(viewModel.content)
                                    .font(Font.light(12))
                                    .foregroundColor(Color.Indigo.DARK)
                                    .padding(.top, 40.5)
                            )
                            
                            LeftAlignedHStack(
                                Text("Overview")
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.medium(15))
                                    .padding(.top, 32)
                            )
                            
                            LeftAlignedHStack(
                                Text(viewModel.overview)
                                    .foregroundColor(Color.Indigo.DARK)
                                    .font(.light(12))
                                    .padding(.top, 20)
                                    
                            )
                            
                            Spacer()
                            
                        }
                        .padding(.top, 48)
                        .padding(.horizontal, 27)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationBarTitle("About Us".localizedString(), displayMode: .inline)
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            })
            .onAppear(perform: viewModel.fetchDetails)
            .listenToAppNotificationClicks()
        }
    }
}

struct AboutUsContentView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsContentView()
    }
}

