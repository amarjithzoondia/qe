//
//  NFDeleteObservationRequestContentView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct NFDeleteObservationRequestContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var description = Constants.EMPTY_STRING
    @StateObject var viewModel: NFDeleteObservationRequestViewModel
    
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
                            Text("open_observation".localizedString())
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.semiBold(17.5))
                        )
                        
                        Spacer()
                        
                        Button {
                            onClose()
                        } label: {
                            Text("back".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        }
                    }
                    
                    LeftAlignedHStack(
                        Text("request_to_delete_observation".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(14))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    )
                    
                    LeftAlignedHStack(
                        Text("observation_delete_description".localizedString())
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.regular(12))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    )
                    
                    VStack(spacing: 0) {
                        LeftAlignedHStack(
                            Text("description".localizedString())
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(12))
                        )
                        
                        LeftAlignedHStack(
                            UIKitStyledTextField(
                                text: $description,
                                placeholder: "description".localizedString(),
                                font: .regular(size: 12),
                                textColor: UIColor(Color.Indigo.DARK),
                                placeholderColor: UIColor(Color.Grey.GUNMENTAL.opacity(0.25)),
                                height: 41,
                                isRTL: LocalizationService.shared.language.isRTLLanguage,
                                keyboardType: .default
                            )
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.medium(12))
                                .modifier(TextFieldInputViewStyle(placeholder: "description".localizedString(), foregroundColor: Color.Grey.LIGHT_GREY_BLUE, text: $description))
                        )
                        .padding(.top, 10)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            requestToDeleteObservation()
                        } label: {
                            Text("continue".localizedString())
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

struct NFDeleteObservationRequestContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFDeleteObservationRequestContentView(viewModel: .init(observationId: -1))
    }
}
