//
//  DraftInspectionsListRowView.swift
// ALNASR
//
//  Created by developer on 16/02/22.
//

import SwiftUI
import SwiftUIX

struct DraftInspectionsListRowView: View {
    private let viewModel = DraftInspectionsListRowViewModel()
    let inspection: Inspections
    let minusButtonTapped: () -> ()
    
    var body: some View {
        VStack {
            VStack(spacing: 11) {
                HStack {
                    Text(inspection.auditItem.auditItemTitle)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(16))
                    
                    Spacer()
                    
                    Button {
                        minusButtonTapped()
                    } label: {
                        Image(IC.ACTIONS.MINUS)
                    }
                }
                
                HStack {
                    
                    HStack(spacing: 11.5) {
                        Image(IC.PLACEHOLDER.CALENDER)
                            .foregroundColor(Color.Green.DARK_GREEN)
                        
                        Text(viewModel.date(inspection: inspection))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.light(12))
                        
                        
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text(viewModel.createdAt(inspection: inspection))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))

                }
                
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
                
                if let facilities = inspection.facilities {
                    HStack(spacing: 6) {
                        WebUrlImage(url: facilities.groupImage.url)
                            .frame(width: 28.5, height: 28.5)
                            .cornerRadius(14.25)
                            .clipped()
                        
                        Text(facilities.groupName)
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.medium(12))
                            .lineLimit(1)
                        
                        Text(facilities.groupCode)
                            .foregroundColor(Color.Grey.SLATE)
                            .font(.regular(12))
                        
                        Spacer()
                    }
                }
                
                LeftAlignedHStack(
                    Text(inspection.description)
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.light(12))
                        .lineLimit(3)
                )
                
                if inspection.images?.count ?? 0 > 0 {
                    HStack(spacing: 9) {
                        if inspection.images?.count ?? 0 == 1 {
                            WebUrlImage(url: inspection.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            WebUrlImage(url: inspection.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack {
                                WebUrlImage(url: inspection.images?[1].image?.url ?? "".url)
                                    .frame(width: 48.5, height: 48.5)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                Spacer()
                                
                            }
                        }
                    }
                    .frame(height: 104.5)
                }
                
                
            }
            .padding(.all, 23)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(.allCorners, 10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
}

struct DraftInspectionsListRowView_Previews: PreviewProvider {
    static var previews: some View {
        DraftInspectionsListRowView(inspection: .dummy(), minusButtonTapped: {})
    }
}

