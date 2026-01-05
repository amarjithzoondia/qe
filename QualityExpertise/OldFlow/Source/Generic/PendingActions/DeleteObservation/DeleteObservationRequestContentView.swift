//
//  DeleteObservationRequestContentView.swift
// ALNASR
//
//  Created by developer on 07/03/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct DeleteObservationRequestContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var description = Constants.EMPTY_STRING
    @StateObject var viewModel: DeleteObservationRequestViewModel
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.35)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    HStack {
                        LeftAlignedHStack(
                            Text("Open Observation")
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.semiBold(17.5))
                        )
                        
                        Spacer()
                        
                        Button {
                            onClose()
                        } label: {
                            Text("Back")
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        }
                    }
                    
                    LeftAlignedHStack(
                        Text("Request to Delete Observation")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(14))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    )
                    
                    LeftAlignedHStack(
                        Text("Provide a short description of why you are requesting this observation to be deleted.")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.regular(12))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    )
                    
                    VStack(spacing: 0) {
                        LeftAlignedHStack(
                            Text("DESCRIPTION")
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(12))
                        )
                        
                        LeftAlignedHStack(
                            TextField(text: $description)
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.medium(12))
                                .modifier(TextFieldInputViewStyle(placeholder: "Description", foregroundColor: Color.Grey.LIGHT_GREY_BLUE, text: $description))
                        )
                        .padding(.top, 10)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            requestToDeleteObservation()
                        } label: {
                            Text("Continue")
                                .foregroundColor(Color.white)
                                .font(.regular(12))
                                .frame(width: 80, height: 35)
                        }
                        .background(Color.Blue.THEME)
                        .cornerRadius(17.5)
                    }
                }
                .padding(.vertical, 41)
                .padding(.horizontal, 27.5)
                .background(Color.white)
                .cornerRadius([.topLeft, .topRight], 25)
            }
            
            VStack {
                if viewModel.isLoading {
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                }
            }
        }
        .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
            viewModel.toast
        }
        .listenToAppNotificationClicks()
    }
    
    private func onClose() {
        viewControllerHolder?.dismiss(animated: true, completion: nil)
    }
    
    func requestToDeleteObservation() {
        viewModel.requestToDeleteObservation(justification: description) { completed in
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
}

struct DeleteObservationRequestContentView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteObservationRequestContentView(viewModel: .init(observationId: -1))
    }
}
