//
//  IncidentListRowView.swift
//  ALNASR
//
//  Created by Amarjith B on 10/09/25.
//

import SwiftUI
import SwiftUIX

struct IncidentListRowView: View {
    
    let incident: Incident
    private let viewModel = IncidentListRowViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 11) {
                HStack {
                    let titles = incident.incidentType
                        .compactMap { IncidentType.from(id: $0)?.title }
                        .prefix(2) // take only first 2

                    Text(titles.joined(separator: "and".localizedString()))
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.semiBold(16))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(viewModel.createdAt(incident: incident))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                }
                
                HStack(spacing: 11.5) {
                    Image(IC.PLACEHOLDER.CALENDER)
                        .foregroundColor(Color.Green.DARK_GREEN)
                    
                    Text(viewModel.date(incident: incident))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    
                    
                    Spacer()
                }
                
                
                
                Divider()
                
                if let facilities = incident.facilities {
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
                    Text(incident.description ?? "")
                        .foregroundColor(Color.Grey.DARK_BLUE)
                        .font(.light(12))
                        .lineLimit(3)
                )
                
                if incident.images?.count ?? 0 > 0 {
                    HStack(spacing: 9) {
                        if incident.images?.count ?? 0 == 1 {
                            WebUrlImage(url: incident.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            WebUrlImage(url: incident.images?[0].image?.url ?? "".url)
                                .frame(height: 97)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack {
                                WebUrlImage(url: incident.images?[1].image?.url ?? "".url)
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
