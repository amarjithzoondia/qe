//
//  DraftToolBoxListRowView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 11/09/25.
//

import SwiftUI
import SwiftUIX

struct DraftToolBoxListRowView: View {
    private let viewModel = DraftToolBoxListRowViewModel()
    let toolBoxTalk: ToolBoxTalk
    let minusButtonTapped: () -> ()
    
    var body: some View {
        VStack {
            VStack(spacing: 11) {
                HStack {
                    Text(toolBoxTalk.topic)
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
                        
                        Text(viewModel.date(toolBox: toolBoxTalk))
                            .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                            .font(.light(12))
                        
                        
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text(viewModel.createdAt(toolBox: toolBoxTalk))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))

                }
                
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
                
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
        .cornerRadius(.allCorners, 10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
}

struct DraftToolBoxListRowView_Previews: PreviewProvider {
    static var previews: some View {
        DraftToolBoxListRowView(toolBoxTalk: .dummmy(), minusButtonTapped: {})
    }
}

