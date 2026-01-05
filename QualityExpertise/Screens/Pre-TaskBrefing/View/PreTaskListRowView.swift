//
//  PreTaskListRowView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 24/10/25.
//


import SwiftUI
import SwiftUIX

struct PreTaskListRowView: View {
    
    let preTask: PreTask
    private let viewModel = PreTaskListRowViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 11) {
                HStack {
                    Text(preTask.taskTitle)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(16))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(viewModel.createdAt(preTask: preTask))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                }
                
                HStack(spacing: 11.5) {
                    Image(IC.PLACEHOLDER.CALENDER)
                        .foregroundColor(Color.Green.DARK_GREEN)
                    
                    Text(viewModel.date(preTask: preTask))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    
                    
                    Spacer()
                }
                
                
                
                Divider()
                
                if let facilities = preTask.facilities {
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
                
                if preTask.images?.count ?? 0 > 0 {
                    HStack(spacing: 9) {
                        if preTask.images?.count ?? 0 == 1 {
                            WebUrlImage(url: preTask.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            WebUrlImage(url: preTask.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack {
                                WebUrlImage(url: preTask.images?[1].image?.url ?? "".url)
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
