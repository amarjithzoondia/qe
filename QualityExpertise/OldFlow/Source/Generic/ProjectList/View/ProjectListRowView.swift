//
//  ProjectListRowView.swift
//  ALNASR
//
//  Created by Amarjith B on 09/04/25.
//

import SwiftUI
import SwiftUIX

struct ProjectListRowView: View {
    @StateObject var viewModel: ProjectListRowViewModel
    
    var body: some View {
        VStack(spacing:0) {
            VStack(spacing: 11) {
                
                headerView
                
                if let description = viewModel.project.projectDescription {
                    descriptionView(description: description)
                }

                clientDetailView
                
                projectImageView
            }
            .padding(23)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
    
    private var headerView: some View {
        HStack(spacing:0) {
            Text(viewModel.project.name)
                .foregroundColor(Color.Indigo.DARK)
                .font(.semiBold(16))
                .lineLimit(2)
            
            Spacer()
            
            Text(viewModel.project.code)
                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                .font(.light(12))
        }
    }
    
    private func descriptionView(description:String) -> some View {
        HStack(spacing: 5) {
            Text("Description :")
                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                .font(.medium(12))
            
            if description.isEmpty {
                
                Text("No Description")
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.light(12))
                    .multilineTextAlignment(.center)
                
                
            } else {
                
                Text(description)
                    .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                    .font(.light(12))
                    .lineLimit(1)
                
            }
            
            Spacer()
        }
    }
    
    var clientDetailView: some View {
        HStack(spacing: 5) {
            
            Text("Client name :")
                .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                .font(.medium(12))
            
            Text(viewModel.project.clientName)
                .foregroundColor(Color.Grey.SLATE)
                .font(.regular(12))
                .lineLimit(1)
            
            Spacer()
        }
    }
    
    private var projectImageView: some View {
        WebUrlImage(url:viewModel.project.image.url)
            .scaledToFill()
            .frame(maxHeight: 97, alignment: .center)
            .cornerRadius(10)
            .clipped()
    }
        

}

#Preview {
    ProjectListRowView(viewModel: .init(project: .dummy()))
}
