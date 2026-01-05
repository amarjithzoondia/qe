
//
//  ContactUsContentView.swift
// QualityExpertise
//
//  Created by developer on 09/02/22.
//

import SwiftUI

struct ContactUsContentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = ContactUsViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State var isActive: Bool = false
    @State var message: String = Constants.EMPTY_STRING
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 46.5) {
                        Image(IC.LOGO.CONTACT_US)
                            .frame(width: 233, height: 179, alignment: .center)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            ContactUsDataDetail(contactUsData: .mail, content: viewModel.email)
//                            ContactUsDataDetail(contactUsData: .phone, content: viewModel.phone)
                            ContactUsDataDetail(contactUsData: .address, content: viewModel.address)
                        }
                        
                        if !(UserManager.getCheckOutUser()?.isGuestUser ?? false) {
                            contactUsView
                            
                            ButtonWithLoader(
                                action: {
                                    sendMessage()
                                },
                                title: "send".localizedString(),
                                width: screenWidth - (2 * 39),
                                height: 41,
                                isLoading: $viewModel.isLoading
                            )
                        }
                    }
                    .padding(.horizontal, 39)
                    .padding(.top, 40)
                }
            }
            .navigationBarTitle("contact_us".localizedString(), displayMode: .inline)
            .toolbar(content: {
                BackButtonToolBarItem {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            })
            .onAppear(perform: viewModel.fetchDetails)
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }

    }
    
    var contactUsView: some View {
        VStack {
            LeftAlignedHStack(
                Text("contact_us".localizedString())
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(17.5))
            )
            
            VStack(spacing: 14) {
                LeftAlignedHStack(
                    Text("full_name".localizedString())
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.regular(12))
                )
                
                LeftAlignedHStack(
                    Text(UserManager().user?.name ?? "")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(13))
                )
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
            .padding(.top, 32.5)
            
            VStack(spacing: 14) {
                LeftAlignedHStack(
                    Text("email".localizedString())
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.regular(12))
                )
                
                LeftAlignedHStack(
                    Text(UserManager().user?.email ?? "")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(13))
                )
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
            .padding(.top, 18)
            
            VStack {
                if isActive {
                    ThemeTextEditorView(text: $message, title: "message".localizedString(), disabled: false, keyboardType: .default, isMandatoryField: false, limit: nil, placeholderColor: Color.Grey.DARK_BLUE, isTitleCapital: true)
                } else {
                    LeftAlignedHStack(
                        Text("message".localizedString())
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .onTapGesture {
                                isActive = true
                            }
                    )
                    
                    Divider()
                        .frame(height: 1)
                        .foregroundColor(Color.Silver.TWO)
                }
            }
            .padding(.top, 10)
        }
    }
    
    func sendMessage() {
        viewModel.sendMessage(message: message)
    }
}

struct ContactUsContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsContentView()
    }
}


extension ContactUsContentView {
    struct ContactUsDataDetail: View {
        
        enum ContactUsData {
            case mail
            case phone
            case address
            
            var icon: String {
                switch self {
                case .mail:
                    return IC.CONTACT_US.EMAIL
                case .phone:
                    return IC.CONTACT_US.PHONE
                case .address:
                    return IC.CONTACT_US.ADDRESS
                }
            }
            
            var title: String {
                switch self {
                case .mail:
                    return "email_us".localizedString()
                case .phone:
                    return "call_us".localizedString()
                case .address:
                    return "address".localizedString()
                }
            }
        }
        
        var contactUsData: ContactUsData
        var content: String
        
        var body: some View {
            HStack(spacing: 15.5) {
                Image(contactUsData.icon)
                    .frame(width: 21, height: 21)
                
                Text(contactUsData.title)
                    .frame(width: 60)
                    .font(Font.medium(12.5))
                    .foregroundColor(Color.Indigo.DARK)
                
                Text(content)
                    .font(Font.regular(12))
                    .foregroundColor(Color.Indigo.DARK)
                Spacer()
            }
            
        }
    }
}


