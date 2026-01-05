//
//  BulkUploadEmployeeView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 12/09/25.
//

import SwiftUI

struct BulkUploadEmployeeView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @State private var showBackButtonalert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var searchText: String = Constants.EMPTY_STRING
    @StateObject var viewModel = BulkUploadEmployeeViewModel()
    
    @Binding var employees: [Employee]   // from parent
    @State private var localEmployees: [Employee] = [] // local copy
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                observersListView
                    .padding(.horizontal, 25)
                    .onAppear {
                        fetchEmployees()
                    }
                
                if !viewModel.employees.isEmpty {
                    VStack {
                        Spacer()
                        bottomFixedButtonView
                    }
                    .ignoresSafeArea()
                }
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .navigationBarTitle("Employees", displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    showBackButtonalert.toggle()
                }, image: Image(IC.INDICATORS.BLACK_BACKWARD_ARROW))
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        localEmployees.removeAll()
                    } label: {
                        Text("Clear All")
                            .foregroundColor(Color.Blue.THEME)
                            .font(.medium(12.5))
                    }
                }
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: $showBackButtonalert, title: "Confirm Exit!".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("Are you sure you want to leave this page, All unsaved changes will be lost.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        showBackButtonalert.toggle()
                    } label: {
                        Text("No")
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("Yes")
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)
            }
        }
        .pickerViewerOverlay(viewerShown: $showSuccessAlert, title: "Employees Selected".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("Employees Selected successfully.")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack{
                    Spacer()
                    
                    Button {
                        employees += localEmployees
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    } label: {
                        Text("Okay")
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
        .navigationBarBackButtonHidden()
    }
    
    var observersListView: some View {
        VStack {
            SearchFieldInputView(
                onEditingChanged: {},
                onDone: { closeKeyboard() },
                text: $searchText,
                placeholder: "Search Employees".localizedString(),
                closeButtonActive: false,
                image: IC.ACTIONS.SEARCH_BLACK,
                foregroundColor: Color.Black.DUSK_TWO,
                font: .regular(15)
            )
            .padding(.top, 30)
            
            if !viewModel.employees.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.employees, id: \.id) { employee in
                            UserListItemView(
                                employee: employee,
                                isSelected: Binding(
                                    get: { localEmployees.contains(where: { $0.id == employee.id }) },
                                    set: { selected in
                                        if selected {
                                            if !localEmployees.contains(where: { $0.id == employee.id }) {
                                                localEmployees.append(employee)
                                            }
                                        } else {
                                            localEmployees.removeAll(where: { $0.id == employee.id })
                                        }
                                    }
                                )
                            )
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 20)
                }
            } else if viewModel.noDataFound {
                "No Employees Found".localizedString()
                    .viewRetry {
                        fetchEmployees()
                    }
                Spacer()
            } else if let error = viewModel.error {
                error.viewRetry {
                    fetchEmployees()
                }
                Spacer()
            }
        }
    }
    
    func fetchEmployees() {
        viewModel.fetchEmployees()
    }
    
    private var bottomFixedButtonView: some View {
        VStack {
            HStack {
                Button {
                    showBackButtonalert = true
                } label: {
                    Text("Close")
                        .foregroundColor(Color.Grey.SLATE)
                        .font(.regular(16.2))
                        .frame(maxWidth: .infinity, minHeight: 85)
                }
                
                if !localEmployees.isEmpty {
                    Divider()
                        .frame(width: 1, height: 37, alignment: .center)
                        .foregroundColor(Color.Silver.TWO)
                    
                    Button {
                        showSuccessAlert = true
                    } label: {
                        Text("Apply")
                            .foregroundColor(Color.Blue.THEME)
                            .font(.regular(16.2))
                            .frame(maxWidth: .infinity, minHeight: 85)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: localEmployees.isEmpty)
                }
            }
        }
        .background(Color.white)
        .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
    }
}

extension BulkUploadEmployeeView {
    struct UserListItemView: View {
        let employee: Employee
        @Binding var isSelected: Bool
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                        .resizable()
                        .frame(width: 48.5, height: 48.5)

                    VStack(spacing: 5) {
                        HStack(spacing: 0) {
                            Text(employee.employeeName)
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(14))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(employee.employeeCode)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                        }
                        
                        LeftAlignedHStack(
                            Text(employee.companyName)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                        )
                        
                        LeftAlignedHStack(
                            Text(employee.profession)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                        )
                    }
                    .padding(.leading, 19)
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.Blue.VERY_LIGHT)
                    .frame(height: 0.5)
                    .padding([.top, .bottom], 12.5)
            }
            .onTapGesture {
                withAnimation {
                    isSelected.toggle()
                }
            }
        }
    }
}

#Preview {
    BulkUploadEmployeeView(employees: .constant([.dummy()]))
}
