//
//  NFDraftObservationListRowView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftUIX

struct NFDraftObservationListRowView: View {
    @State var viewModel = NFDraftObservationListRowViewModel()
    @Binding var minusButtonTapped: Bool
    @Binding var dbId: Int
    @Binding var observation: NFObservationDraftData
    
    var body: some View {
        VStack {
            VStack(spacing: 11) {
                HStack {
                    Text(observation.observationTitle)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(16))
                    
                    Spacer()
                    
                    Button {
                        minusButtonTapped.toggle()
                        dbId = observation.id
                    } label: {
                        Image(IC.ACTIONS.MINUS)
                    }
                }
                
                HStack(spacing: 11.5) {
                    Image(IC.PLACEHOLDER.CALENDER)
                        .foregroundColor(Color.Green.DARK_GREEN)
                    
                    Text(viewModel.date(date: observation.createdAt))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    Spacer()
                    
                    Text(viewModel.time(createdTime: observation.createdAt))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                }
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
                
                if let facilities = observation.facilites {
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
                
                if let description = observation.description, !description.isEmpty {
                    LeftAlignedHStack(
                        Text(description)
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.light(12))
                            .lineLimit(3)
                    )
                }
                
                if observation.imageDescription?.count ?? 0 > 0 {
                    HStack(spacing: 9) {
                        if observation.imageDescription?.count ?? 0 == 1 {
                            WebUrlImage(url: observation.imageDescription?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            WebUrlImage(url: observation.imageDescription?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack {
                                WebUrlImage(url: observation.imageDescription?[1].image?.url ?? "".url)
                                    .frame(width: 48.5, height: 48.5)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                Spacer()
                                
                            }
                        }
                    }
                    .frame(height: 104.5)
                    .clipped()
                    .allowsHitTesting(false)

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

