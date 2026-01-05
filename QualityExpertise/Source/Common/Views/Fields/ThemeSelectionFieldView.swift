//
//  ThemeSelectionFieldView.swift
// QualityExpertise
//
//  Created by developer on 01/03/22.
//

import SwiftUI

struct ThemeSelectionFieldView: View {
    var title: String
    var value: String?
    var disabled = false
    @Binding var isSelected: Bool
    var showTitle = true
    var isMandatoryField = false
    var action: () -> () = {}

    var body: some View {
        VStack(spacing: 0) {
            if showTitle {
                LeftAlignedHStack(
                    (Text(title).foregroundColor(Color.Blue.BLUE_GREY) + Text(isMandatoryField ? " *" : "").foregroundColor(Color.Red.CORAL))
                        .font(.regular())
                )
            }
            
            Button(action: {
                isSelected.toggle()
            }, label: {
                LeftAlignedHStack(
                    Group {
                        if let value = value {
                            HStack {
                                Text(value)
                                    .foregroundColor(Color.Indigo.DARK)
                                
                                Spacer()
                                
                                Button {
                                    action()
                                } label: {
                                    Image(IC.ACTIONS.CLOSE)
                                }

                            }
                        } else {
                            Text(title.selectPlaceholder)
                                .foregroundColor(Color.Grey.SLATE)
                        }
                    }
                    .font(.medium(14))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                )
                
            })
            .disabled(disabled)
            .frame(height: 42)
            
            Divider()
                .frame(height: 1)
                .foregroundColor(Color.Silver.TWO)
        }
    }
}

struct ThemeSelectionFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSelectionFieldView(title: "Test", isSelected: .constant(true))
    }
}

