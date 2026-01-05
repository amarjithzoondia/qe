//
//  ResponsiblePersonChangeContentView.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ResponsiblePersonChangeContentView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel: ResponsiblePersonChangeViewModel
    @State var description = Constants.EMPTY_STRING
    @State var userData: UserData?
    @State var isUserSelect: Bool = false
    
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
                        Text("request_responsibility_change".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.medium(14))
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    )
                    
                    LeftAlignedHStack(
                        Text("new_responsible_person".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(12))
                    )
                    
                    if isUserSelect {
                        VStack {
                            VStack {
                                HStack {
                                    WebUrlImage(url: userData?.image.url, placeholderImage: Image(IC.PLACEHOLDER.USER))
                                        .frame(width: 45.5, height: 45.5)
                                        .cornerRadius(22.25)
                                    
                                    VStack(spacing: 10) {
                                        LeftAlignedHStack(
                                            Text(userData?.name ?? "")
                                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                                .font(.medium(15))
                                        )
                                        
                                        LeftAlignedHStack(
                                            Text(userData?.email ?? "")
                                                .foregroundColor(Color.Grey.SLATE)
                                                .font(.regular(12))
                                        )
                                    }
                                    .padding(.leading, 12.5)
                                    
                                    Spacer()
                                    
                                    Button {
                                        isUserSelect.toggle()
                                    } label: {
                                        Text("remove".localizedString())
                                            .foregroundColor(Color.Blue.THEME)
                                            .font(.regular(12))
                                    }

                                }
                                .padding(.vertical, 19)
                                .padding(.horizontal, 16)
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
                        }
                    } else {
                        Button {
                            viewControllerHolder?.present(style: .overCurrentContext) {
                                UserListContentView(viewModel: .init(groupData: viewModel.groupData), isFromSelectAUser: true, isFromViewGroup: true, isUserActive: $isUserSelect, isUserActiveForNotification: .constant(false), userData: $userData, userDatas: .constant([UserData.dummy()]))
                                    .localize()
                            }
                        } label: {
                            Text("select_user".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.medium(15))
                                .frame(width: screenWidth - (27.5 + 27.5 + 15 + 15), height: 53)
                        }
                        .background(Color.Blue.PALE_GREY)
                        .cornerRadius(10)
                    }
                    
                    LeftAlignedHStack(
                        Text("responsible_person_change_description".localizedString())
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
                            changeResponsibility()
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
    
    func changeResponsibility() {
        viewModel.responsiblePersonChange(description: description, userId: userData?.userId ?? -1) { completed in
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
    }
}
