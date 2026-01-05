//
//  NotificationListRowView.swift
// ALNASR
//
//  Created by developer on 07/03/22.
//

import SwiftUI

struct NotificationListRowView: View {
    let viewModel: NotificationListRowViewModel
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                HStack {
                    Text(viewModel.notification.title ?? "")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.medium(14))
                    
                    Spacer()
                    
                    Text(viewModel.timeText)
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.light(12))
                }
                
                HStack(spacing: 11.5) {
                    Image(IC.PLACEHOLDER.CALENDER)
                        .foregroundColor(Color.Green.DARK_GREEN)
                    
                    Text(viewModel.dateText)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    Text(viewModel.groupCode)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    Spacer()
                }
                
                LeftAlignedHStack(
                    Text(viewModel.notification.description ?? "")
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.light(12))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                )
                .padding(.top, 4)
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
                    .padding(.top, 6.5)
                
            }
            .padding([.horizontal, .top], 27)
        }
        .background(viewModel.notification.isRead ?? false ? Color.white : Color.Grey.PALE_THREE)
    }
}
