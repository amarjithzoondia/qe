//
//  AuditInspectionsView.swift
//  ALNASR
//
//  Created by Amarjith B on 03/06/25.
//

import SwiftUI

struct AuditsInspectionsView: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @StateObject var viewModel = AuditInspectionsViewModel()
    @Binding var isListChanged: Bool
    @State var showComingSoonAlert: Bool = false
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                if viewModel.noDataFound {
                    "no_audits_inspections_form_found".localizedString()
                        .viewRetry {
                            viewModel.fetchList()
                    }
                    Spacer()
                } else if let error = viewModel.error {
                    error.viewRetry(isError: true) {
                        viewModel.fetchList()
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.inspectionsList) { item in
                                    NavigationLink {
                                        CreateEquipmentStaticView(
                                            viewModel: .init(
                                                inspectionID: nil,
                                                inspection: nil,
                                                draftInspection: nil,
                                                inspectionTypeID: item.auditItemId),
                                            isListChanged: $isListChanged,
                                            inspectionType: item
                                        )
                                        .localize()
                                    } label: {
                                        inspectionRow(for: item)
                                    }
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 34)
                        .padding(.top, 20)
                    }
                }
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
                if showComingSoonAlert {
                    
                    VStack {
                        Spacer()
                        Text("coming_soon".localizedString())
                            .font(.medium(12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(30)
                    }
                    
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showComingSoonAlert = false
                            }
                        }
                    }
                }
            }
            .toolbar {
                    BackButtonToolBarItem(action: {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    })
            }
            .onAppear {
                viewModel.fetchList()
                print(viewModel.inspectionsList)
            }
            .navigationBarTitle("audits_inspection".localizedString(), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            
        }
    }
    
    @ViewBuilder
    func inspectionRow(for item: AuditsInspectionsList) -> some View {
        HStack(spacing: 20) {
            WebUrlImage(url:item.image?.url)
                .frame(width: 39, height: 39)
                .cornerRadius(29.25)
            
            Text(item.auditItemTitle)
                .font(.regular(16))
                .multilineTextAlignment(.leading)
                .foregroundColor(.black)
                .leftAlign()
            
            Spacer()
            
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .rotationEffect(layoutDirection == .rightToLeft ? .degrees(180) : .degrees(0))
            
        }
        .padding(.vertical, 10)
    }


}

#Preview {
    AuditsInspectionsView(isListChanged: .constant(false))
}

