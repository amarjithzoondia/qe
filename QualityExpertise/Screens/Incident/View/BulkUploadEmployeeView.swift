//
//  BulkUploadEmployeeView.swift
//  ALNASR
//
//  Created by Amarjith B on 12/09/25.
//

import SwiftUI

struct BulkUploadEmployeeView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var showBackButtonalert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var closeButtonActive = false
    @State private var searchText: String = Constants.EMPTY_STRING
    @StateObject var viewModel = BulkUploadEmployeeViewModel()
    
    var groupData: GroupData
    
    @Binding var employees: [Employee]   // from parent
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                        // Search field
                        SearchFieldInputView(
                            onEditingChanged: {
                                viewModel.resetPagination()
                                fetchEmployees(isInital: true)
                            },
                            onDone: {
                                closeKeyboard()
                                viewModel.resetPagination()
                                fetchEmployees(isInital: true)
                            },
                            text: $searchText,
                            placeholder: "search_employees".localizedString(),
                            closeButtonActive: closeButtonActive,
                            foregroundColor: Color.Indigo.DARK,
                            background: Color.white,
                            placeholderColor: Color.Indigo.DARK,
                            onCloseClicked: {
                                viewModel.resetPagination()
                                fetchEmployees(isInital: true)
                            }
                        )
//                        .onChange(of: isListSorted, perform: { (value) in
//                            viewModel.sortViolation(searchText: searchText, sortType: isListSorted ? .ascending : .descending)
//                        })
                        .onChange(of: searchText) { _ in
                            viewModel.resetPagination()
                            fetchEmployees(isInital: true)
                        }
                        .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                        .onChange(of: searchText) { value in
                            closeButtonActive = !value.isEmpty
                        }
//                        .onChange(of: isListChanged) { value in
//                            if value {
//                                fetchEmployees()
//                                isListChanged = false
//                            }
//                        }
                        .padding(.horizontal, 27)
                        .padding(.top, 10)
                    
                        
                    observersListView
                    }
                
                
                if viewModel.employees.count > 0 {
                    VStack {
                        Spacer()
                        
                        bottomFixedButtonView
                        
                        .frame(height: 80)
                        .background(Color.white)
                        
                        
                    }
                    .ignoresSafeArea()
                    
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .navigationBarTitle("employees".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    presentationMode.wrappedValue.dismiss()
                })

            }
            .onAppear {
                fetchEmployees(isInital: true)
                
            }
            .listenToAppNotificationClicks()
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden()
        .pickerViewerOverlay(viewerShown: $showBackButtonalert, title: "confirm_exit".localizedString()) {
                    VStack {
                        LeftAlignedHStack(
                            Text("confirm_exit_message".localizedString())
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.regular(14))
                        )
                        
                        HStack {
                            Button {
                                showBackButtonalert.toggle()
                            } label: {
                                Text("no".localizedString())
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
                                Text("yes".localizedString())
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
                .pickerViewerOverlay(viewerShown: $showSuccessAlert, title: "employees_selected".localizedString()) {
                    VStack {
                        LeftAlignedHStack(
                            Text("employees_selected_successfully".localizedString())
                                .foregroundColor(Color.Indigo.DARK)
                                .font(.regular(14))
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
                    }
                }
    }
    
    var observersListView: some View {
        
        VStack {
            // Content area
            if viewModel.noDataFound {
                "no_employees_found".localizedString()
                    .viewRetry {
                        fetchEmployees()
                    }
                Spacer()
                
            } else if let error = viewModel.error {
                error.viewRetry(isError: true) {
                    fetchEmployees()
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.employees.indices, id: \.self) { index in
                            let employee = viewModel.employees[index]
                            let isSelectedBinding = Binding<Bool>(
                                    get: { employees.contains(where: { $0.id == employee.id }) },
                                    set: { newValue in
                                        if newValue {
                                            if !employees.contains(where: { $0.id == employee.id }) {
                                                employees.append(employee)
                                            }
                                        } else {
                                            employees.removeAll(where: { $0.id == employee.id })
                                        }
                                    }
                                )
                            UserListItemView(employee: employee, groupData: groupData, isSelected: isSelectedBinding, index: index, viewModel: viewModel, searchText: searchText)
                        }
                    }
                    .padding(.horizontal, 27)
                    .padding(.bottom, 65)
                    .padding(.top, 12)
                }
                .padding(.top, 10)
            }
        }
        
    }
    
    func fetchEmployees(isInital: Bool = false) {
        viewModel.fetchEmployees(searchText: searchText, sortType: .descending, isInital: isInital, groupData: groupData)
    }
    
    private var bottomFixedButtonView: some View {
        VStack {
            HStack {
                Button {
                    showBackButtonalert = true
                } label: {
                    Text("close".localizedString())
                        .foregroundColor(Color.Grey.SLATE)
                        .font(.regular(16.2))
                        .frame(maxWidth: .infinity, minHeight: 85)
                }
                
                if !employees.isEmpty {
                    Divider()
                        .frame(width: 1, height: 37, alignment: .center)
                        .foregroundColor(Color.Silver.TWO)
                    
                    Button {
                        showSuccessAlert = true
                    } label: {
                        Text("apply".localizedString())
                            .foregroundColor(Color.Blue.THEME)
                            .font(.regular(16.2))
                            .frame(maxWidth: .infinity, minHeight: 85)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: employees.isEmpty)
                }
            }
        }
        .background(Color.white)
        .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
    }
}

struct UserListItemView: View {
    let employee: Employee
    let groupData: GroupData
    @Binding var isSelected: Bool
    let index: Int
    let viewModel: BulkUploadEmployeeViewModel
    let searchText: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                    .resizable()
                    .frame(width: 48, height: 48) // Reduced size for better alignment
                    .padding(.leading, 8)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(employee.employeeName)
                                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                                .font(.medium(14))
                                .lineLimit(1)
                            
                            Text(employee.companyName ?? Constants.NOTHING)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                            
                            Text(employee.profession ??  Constants.NOTHING)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Spacer()
                            Text(employee.employeeCode ?? Constants.NOTHING)
                                .foregroundColor(Color.Grey.SLATE)
                                .font(.regular(13))
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            Divider()
                .background(Color.Blue.VERY_LIGHT)
                .frame(height: 0.5)
        }
        .onTapGesture {
            withAnimation {
                isSelected.toggle()
            }
        }
        .onAppear {
            // Load more data when reaching the end of the list
            if viewModel.employees.count - 1 == index {
                viewModel.fetchEmployees(searchText: searchText, sortType: .ascending, isInital: false, groupData: groupData)
            }
        }
    }
}

#Preview {
    BulkUploadEmployeeView(groupData: .dummy(), employees: .constant([Employee.dummy()]))
}
