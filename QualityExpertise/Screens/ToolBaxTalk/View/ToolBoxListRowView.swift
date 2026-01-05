//
//  ToolBoxListRowView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 10/09/25.
//

import SwiftUI
import SwiftUIX

struct ToolBoxListRowView: View {
    
    let toolBoxTalk: ToolBoxTalk
    private let viewModel = ToolBoxListRowViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 11) {
                HStack {
                    Text(toolBoxTalk.topic)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(16))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(viewModel.createdAt(toolBoxTalk: toolBoxTalk))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                }
                
                HStack(spacing: 11.5) {
                    Image(IC.PLACEHOLDER.CALENDER)
                        .foregroundColor(Color.Green.DARK_GREEN)
                    
                    Text(viewModel.date(toolBoxTalk: toolBoxTalk))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    
                    
                    Spacer()
                }
                
                
                
                Divider()
                
                if let facilities = toolBoxTalk.facilities {
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
                
//                LeftAlignedHStack(
//                    Text(toolBoxTalk.description ?? "")
//                        .foregroundColor(Color.Grey.DARK_BLUE)
//                        .font(.light(12))
//                        .lineLimit(3)
//                )
                
                if toolBoxTalk.images?.count ?? 0 > 0 {
                    HStack(spacing: 9) {
                        if toolBoxTalk.images?.count ?? 0 == 1 {
                            WebUrlImage(url: toolBoxTalk.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            WebUrlImage(url: toolBoxTalk.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack {
                                WebUrlImage(url: toolBoxTalk.images?[1].image?.url ?? "".url)
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
        .cornerRadius(10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
}

#Preview {
    IncidentListRowView(incident: .dummmy())
}
