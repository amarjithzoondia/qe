//
//  ToolBoxListView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

import SwiftUI


struct ToolBoxListView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var searchText = Constants.EMPTY_STRING
    @State private var closeButtonActive = false
    @State private var isListSorted: Bool = false
    
    @State private var isListChanged = false
    
    @StateObject private var viewModel = ToolBoxListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header with Add New button
                    
                        HStack {
                            HStack(spacing: 15) {
                                Image(IC.ACTIONS.PLUS)
                                    .foregroundColor(Color.Green.DARK_GREEN)
                                
                                Text("Add New")
                                    .font(.light(12))
                                    .foregroundColor(Color.Blue.THEME)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 27)
                            .padding(.top, 16)
                            .onTapGesture {
                                viewControllerHolder?.present(style: .overCurrentContext) {
//                                    CreateViolationView(
//                                        violation: nil,
//                                        draftViolation: nil,
//                                        onSuccess: {
//                                            viewModel.resetPagination()
//                                            fetchList(isInital: true)
//                                        }
//                                    )
                                    CreateIncidentView(
                                        incident: nil,
                                        onSuccess: {
                                            viewModel.resetPagination()
                                            fetchList(isInital: true)
                                        }
                                    )
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(IC.VIOLATIONS.DRAFT)
                                    .foregroundColor(Color.Green.DARK_GREEN)
                                
                                Text("Drafts")
                                    .font(.light(12))
                                    .foregroundColor(Color.Blue.THEME)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 27)
                            .padding(.top, 16)
                            .onTapGesture {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    DraftIncidentListContentView(onNewIncidentAdded: {
                                        viewModel.resetPagination()
                                        fetchList(isInital: true)
                                    })
                                }
                            }
                        }
                    
                    
                        // Search field
                        SearchFieldInputView(
                            onEditingChanged: {
                                viewModel.resetPagination()
                                fetchList(isInital: true)
                            },
                            onDone: {
                                closeKeyboard()
                                viewModel.resetPagination()
                                fetchList(isInital: true)
                            },
                            text: $searchText,
                            placeholder: "Search Incidents".localizedString(),
                            closeButtonActive: closeButtonActive,
                            foregroundColor: Color.Indigo.DARK,
                            background: Color.white,
                            placeholderColor: Color.Indigo.DARK,
                            onCloseClicked: {
                                viewModel.resetPagination()
                                fetchList(isInital: true)
                            }
                        )
                        .onChange(of: isListSorted, perform: { (value) in
                            viewModel.sortViolation(searchText: searchText, sortType: isListSorted ? .ascending : .descending)
                        })
                        .onChange(of: searchText) { _ in
                            viewModel.resetPagination()
                            fetchList(isInital: true)
                        }
                        .shadow(color: Color.Blue.POWDERED_76, radius: 5, x: 1, y: 1)
                        .onChange(of: searchText) { value in
                            closeButtonActive = !value.isEmpty
                        }
                        .onChange(of: isListChanged) { value in
                            if value {
                                fetchList()
                                isListChanged = false
                            }
                        }
                        .padding(.horizontal, 27)
                        .padding(.top, 10)
                    
                        
                        listView
                    }
                
                
                if viewModel.searchIncidents.count > 0 {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                exportToExcel()
                            } label: {
                                Text("Export to Excel")
                                    .foregroundColor(Color.Blue.THEME)
                                    .font(.medium(16))
                                    .frame(maxWidth: 150, minHeight: 45)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22.5)
                                            .stroke(Color.Blue.THEME, lineWidth: 0.5)
                                    )
                                    .padding(.bottom, 35)
                            }
                            .background(Color.white)
                            
                            Spacer()
                        }
                        
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
            .navigationBarTitle("Incidents", displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    presentationMode.wrappedValue.dismiss()
                })
                ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isListSorted.toggle()
                        } label: {
                            Image(isListSorted ? IC.ACTIONS.SORT_REVERSE : IC.ACTIONS.SORT)
                        }
                }
            }
            .onAppear {
                fetchList()
                
            }
            .listenToAppNotificationClicks()
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden()
    }
    
    var listView: some View {
        VStack {
            // Content area
            if viewModel.noDataFound {
                "No Incidents found".localizedString()
                    .viewRetry {
                        fetchList()
                    }
                Spacer()
                
            } else if let error = viewModel.error {
                error.viewRetry {
                    fetchList()
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchIncidents.indices, id: \.self) { index in
                            let incident = viewModel.searchIncidents[index]
                            IncidentListRowView(incident: incident)
                            .onTapGesture {
                                viewControllerHolder?.present(style:.overCurrentContext) {
                                    CreateIncidentView(
                                        incident: incident,
                                        isViewOnly: true,
                                        onSuccess: {
                                            
                                        })
                                }
                            }
                            .onAppear {
                                if viewModel.searchIncidents.count - 1 == index {
                                    fetchList()
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 27)
                    .padding(.bottom, 65) // Space for export button
                }
                .padding(.top, 10)
            }
        }
    }
    
    private func fetchList(isInital: Bool = false) {
        viewModel.fetchIncidentsList(searchText: searchText, sortType: isListSorted ? .ascending : .descending, isInital: isInital)
    }
    
    private func exportToExcel() {
        viewModel.exportToExcel(searchKey: searchText ,sortType: isListSorted ? .ascending : .descending) {
            saveExcel(urlString: viewModel.excelUrl)
        }
    }
    
    private func saveExcel(urlString: String) {
        guard let url = URL(string: urlString),
              let pdfData = try? Data(contentsOf: url) else {
            viewModel.toast = Toast.alert(subTitle: "Failed to download Excel file")
            return
        }
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "QualityExpertise-Excel \(Date().timeIntervalSince1970).csv"
        let filePath = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: filePath, options: .atomic)
            viewModel.toast = "Excel successfully saved!".successToast
        } catch {
            viewModel.toast = Toast.alert(subTitle: "Excel could not be saved")
        }
    }
}



// MARK: - Preview

struct IncidentListView_Previews: PreviewProvider {
    static var previews: some View {
        IncidentListView()
    }
}
