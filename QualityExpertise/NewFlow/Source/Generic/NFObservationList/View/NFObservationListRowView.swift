//
//  NFObservationListRowView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/06/25.
//

import SwiftUI
import SwiftUIX

struct NFObservationListRowView: View {
    let viewModel: NFObservationListRowViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: 11) {
                HStack {
                    Text(viewModel.observation.observationTitle)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(16))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(viewModel.time)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                }
                
                HStack(spacing: 11.5) {
                    Image(IC.PLACEHOLDER.CALENDER)
                        .foregroundColor(Color.Green.DARK_GREEN)
                    
                    Text(viewModel.date)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    VStack {
                        Text(viewModel.observation.status.description)
                            .foregroundColor(Color.white)
                            .font(.light(12))
                            .padding(.horizontal, 10)
                    }
                    .background(viewModel.observation.status.backGroundColor)
                    .cornerRadius(3.5)
                    
                    Spacer()
                }
                
                if viewModel.observation.group != nil {
                    HStack(spacing: 6) {
                        WebUrlImage(url: viewModel.observation.group?.groupImage.url)
                            .frame(width: 28.5, height: 28.5)
                            .cornerRadius(14.25)
                            .clipped()
                        
                        Text(viewModel.observation.group?.groupName ?? "")
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.medium(12))
                            .lineLimit(1)
                        
                        Text(viewModel.observation.group?.groupCode ?? "")
                            .foregroundColor(Color.Grey.SLATE)
                            .font(.regular(12))
                        
                        Spacer()
                    }
                }
                
                LeftAlignedHStack(
                    Text(viewModel.observation.description)
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.light(12))
                        .lineLimit(3)
                )
                
                if viewModel.observation.totalImages > 0 {
                    HStack(spacing: 9) {
                        if viewModel.observation.totalImages == 1 {
                            WebUrlImage(url: viewModel.observation.images[0].url)
                                .scaledToFill()
                                .frame(maxHeight: 97, alignment: .center)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            WebUrlImage(url: viewModel.observation.images[0].url)
                                .scaledToFill()
                                .frame(maxHeight: 97, alignment: .center)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack {
                                WebUrlImage(url: viewModel.observation.images[1].url)
                                    .frame(width: 48.5, height: 48.5)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                Spacer()
                                
                                if viewModel.observation.totalImages > 2 {
                                    VStack {
                                        Text(viewModel.remainingImagesCount)
                                            .foregroundColor(Color.white)
                                            .font(.semiBold(12))
                                    }
                                    .frame(width: 48.5, height: 48.5)
                                    .background(Color.Blue.THEME)
                                    .cornerRadius(10)                               }
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
        .cornerRadius(10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
}

struct NFObservationListRowView_Previews: PreviewProvider {
    static var previews: some View {
        NFObservationListRowView(viewModel: .init(observation: Observation.dummy(observationId: -1)))
    }
}
