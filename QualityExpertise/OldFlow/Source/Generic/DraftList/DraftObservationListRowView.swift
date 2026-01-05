//
//  DraftObservationListRowView.swift
// ALNASR
//
//  Created by developer on 16/02/22.
//

import SwiftUI
import SwiftUIX

struct DraftObservationListRowView: View {
    @State var viewModel = DraftObservationListRowViewModel()
    @Binding var minusButtonTapped: Bool
    @Binding var dbId: Int
    @Binding var observation: ObservationDraftData
    
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
                    
                    Text(viewModel.date(date: observation.createdTime))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                    
                    Spacer()
                }
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
                
                LeftAlignedHStack(
                    Text(viewModel.time(createdTime: observation.createdTime, updatedTime: observation.updatedTime))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)
                        .font(.light(12))
                )
            }
            .padding(.all, 23)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(.allCorners, 10)
        .shadow(color: Color.Indigo.DUSK_FOUR_15, radius: 5, x: 1, y: 1)
    }
}

struct DraftObservationListRowView_Previews: PreviewProvider {
    static var previews: some View {
        DraftObservationListRowView(minusButtonTapped: .constant(false), dbId: .constant(-1), observation: .constant(ObservationDraftData(id: -1, observationTitle: "", reportedBy: "", location: "", description: "", responsiblePersonName: "", imageDescription: [], createdTime: "", updatedTime: "")))
    }
}

