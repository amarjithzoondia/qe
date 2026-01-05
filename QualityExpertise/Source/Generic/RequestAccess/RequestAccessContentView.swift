//
//  RequestAccessContentView.swift
// QualityExpertise
//
//  Created by developer on 30/01/22.
//

import SwiftUI
import SwiftUIX
import SwiftfulLoadingIndicators

struct RequestAccessContentView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = RequestAccessViewModel()
    @State var groupShortCode = Constants.EMPTY_STRING
    @State var groupId = Constants.EMPTY_STRING
    @State var isSecondTextFieldActive = false
    @State var groupCodeHyphen = Constants.HYPHEN
    @State var isViewGroup = false
    @State var isRequestSuccess = false
    @State private var isGroupVerified = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        Image(IC.LOGO.REQUEST_ACCESS)
                            .resizable()
                            .frame(width: 240, height: 180)
                        
                        Text("group_access_request".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(21))
                            .padding(.top, 15)
                            .multilineTextAlignment(.center)
                        
                        Text("enter_code_to_join_group".localizedString())
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(13.5))
                            .padding(.top, 11.5)
                            .multilineTextAlignment(.center)
                        
                        codeView
                            .padding(.top, 26.5)
                        
                        Button {
                            viewGroup()
                        } label: {
                            Text("view_group".localizedString())
                                .foregroundColor(Color.Blue.THEME)
                                .font(.regular(12))
                        }
                        .padding(.top, 20.5)
                        
                        Button {
                            requetToGroup()
                        } label: {
                            Text("continue".localizedString())
                                .foregroundColor(Color.white)
                                .font(.medium(16))
                                .frame(maxWidth: .infinity, minHeight: 45)
                        }
                        .background(Color.Blue.THEME)
                        .cornerRadius(22.5)
                        .padding(.top, 14.5)

                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 53.5)
                .padding(.top, 21.5)
                
                if viewModel.isLoading {
                    Color.white.opacity(0.75)
                        .edgesIgnoringSafeArea(.all)
                    LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                }
            }
            .navigationBarTitle("request_access".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: $isViewGroup, title: viewModel.isGroupVerified ? "" : "incorrect_code".localizedString()) {
            if viewModel.isGroupVerified {
                VStack {
                    VStack(spacing: 20) {
                        WebUrlImage(url: viewModel.groupDetail?.groupImage.url, placeholderImage: Image(IC.PLACEHOLDER.GROUP))
                            .frame(width: 102, height: 102)
                            .cornerRadius(102/2)
                            .clipped()
                        
                        Text(viewModel.groupDetail?.groupName ?? "")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.semiBold(17.5))
                        
                        Text(viewModel.groupDetail?.groupCode ?? "")
                            .foregroundColor(Color.Indigo.DARK)
                            .font(.regular(15))
                        
                        if let description = viewModel.groupDetail?.description {
                            Text(description)
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.light(12))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 25.5)
                }
            } else {
                LeftAlignedHStack(
                    Text("group_not_exist_view".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(15))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        isViewGroup.toggle()
                    } label: {
                        Text("okay".localizedString())
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                    }
                    .frame(width: 80, height: 35)
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.vertical, 15)
                .padding(.trailing, 15)
            }
        }
        .pickerViewerOverlay(viewerShown: $isRequestSuccess, title: viewModel.isGroupVerified ? "access_requested".localizedString() : "incorrect_code".localizedString()) {
            if viewModel.isGroupVerified {
                LeftAlignedHStack(
                    Text("group_access_requested".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(15))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("okay".localizedString())
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                    }
                    .frame(width: 80, height: 35)
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.vertical, 15)
                .padding(.trailing, 15)
                
            } else {
                LeftAlignedHStack(
                    Text("group_not_exist_join".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(15))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        isRequestSuccess.toggle()
                    } label: {
                        Text("okay".localizedString())
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                    }
                    .frame(width: 80, height: 35)
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.vertical, 15)
                .padding(.trailing, 15)
            }
        }
    }
    
    var codeView: some View {
        HStack {
            ZStack {
                Color.Grey.PALE
                
                if groupShortCode.isEmptyOrWhitespace() {
                    Text("----")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(22))
                }
                
                TextField("", text: $groupShortCode)
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(22))
                    .multilineTextAlignment(.center)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .keyboardType(.asciiCapable)
                    .frame(maxWidth: .infinity, minHeight: 57.5)
                    .background(Color.clear)
                    .onChange(of: groupShortCode, perform: { value in
                        if groupShortCode.count < Constants.Number.Limit.GROUPCODEPARTONE {
                            isSecondTextFieldActive = false
                        } else {
                            groupShortCode = value.fieldLimit(limit: Constants.Number.Limit.GROUPCODEPARTONE)
                            isSecondTextFieldActive = true
                        }
                    })
            }
            .cornerRadius(7.5)
            
            
            Text(groupCodeHyphen)
                .foregroundColor(Color.Indigo.DARK)
                .font(.semiBold(22.5))
            
            ZStack {
                Color.Grey.PALE
                
                if groupId.isEmptyOrWhitespace() {
                    Text("-----")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(22))
                    
                }
                
                CocoaTextField("", text: $groupId)
                    .foregroundColor(Color.Indigo.DARK)
                    .font(.semiBold(size: 22.5))
                    .keyboardType(.numberPad)
                    .autocapitalization(.allCharacters)
                    .isFirstResponder(isSecondTextFieldActive)
                    .frame(maxWidth: .infinity, minHeight: 57.5)
                    .background(Color.clear)
                    .cornerRadius(7.5)
                    .multilineTextAlignment(.center)
                    .onChange(of: groupId, perform: { value in
                        if groupId.count >= Constants.Number.Limit.GROUPCODEPARTTWO {
                            groupId = value.fieldLimit(limit: Constants.Number.Limit.GROUPCODEPARTTWO)
                        }
                    })
            }
            .cornerRadius(7.5)
        }
    }
    
    func viewGroup() {
        viewModel.viewGroup(groupId: groupId, groupShortCode: groupShortCode, notificationId: -1) { completed in
            isViewGroup.toggle()
        }
    }
    
    func requetToGroup() {
        closeKeyboard()
        
        viewModel.requestToGroup(groupId: groupId, groupShortCode: groupShortCode) { completed in
            isRequestSuccess.toggle()
        }
    }
}

struct RequestAccessContentView_Previews: PreviewProvider {
    static var previews: some View {
        RequestAccessContentView()
    }
}
