//
//  PendingActionRowView.swift
// QualityExpertise
//
//  Created by developer on 02/03/22.
//

import SwiftUI

struct PendingActionRowView: View {
    let viewModel: PendingActionRowViewModel
    var isEditable: Bool = false
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Text(viewModel.timeText)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.regular(12))
                }
                
                LeftAlignedHStack(
                    VStack {
//                        Text(!isEditable ? PendingActionType.openObservation.description : viewModel.pendingActionDetails.type.description)
//                            .foregroundColor(viewModel.pendingActionDetails.type.textColor)
//                            .font(.regular(12))
//                            .padding(.all, 7)
                        
                        if isEditable {
                            Text(viewModel.pendingActionDetails.type.description)
                                .foregroundColor(viewModel.pendingActionDetails.type.textColor)
                                .font(.regular(12))
                                .padding(.all, 7)
                        } else if viewModel.pendingActionDetails.type == .reviewObservationCloseOut && !isEditable {
                            Text( PendingActionType.openObservation.description)
                                .foregroundColor( PendingActionType.openObservation.textColor)
                                .font(.regular(12))
                                .padding(.all, 7)
                        } else {
                            Text(viewModel.pendingActionDetails.type.description)
                                .foregroundColor(viewModel.pendingActionDetails.type.textColor)
                                .font(.regular(12))
                                .padding(.all, 7)
                        }
                    }
                     .background(
                            isEditable ? viewModel.pendingActionDetails.type.backgroundColor :
                            (viewModel.pendingActionDetails.type == .reviewObservationCloseOut ?
                             PendingActionType.openObservation.backgroundColor :
                             viewModel.pendingActionDetails.type.backgroundColor)
                        )
                    .cornerRadius(3.5)
                )
                .padding(.top, 13)
                
                HStack {
                    Image(IC.PLACEHOLDER.CALENDER)
                    
                    Text(viewModel.dateText)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.regular(12))
                        .padding(.leading, 8.5)
                    
                    Text(viewModel.pendingActionDetails.groupCode)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.regular(12))
                        .padding(.leading, 17.5)
                    
                    Spacer()
                }
                .padding(.top, 13)
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
                    .padding(.top, 13)
                
                LeftAlignedHStack(
                    Text(viewModel.pendingActionDetails.description)
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.regular(12))
                        .lineLimit(nil)
                )
                .padding(.top, 13)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 21.5)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
}

struct PendingActionRowView_Previews: PreviewProvider {
    static var previews: some View {
        PendingActionRowView(viewModel: .init(pendingActionDetails: PendingActionDetails.dummy(id: -1)))
    }
}
