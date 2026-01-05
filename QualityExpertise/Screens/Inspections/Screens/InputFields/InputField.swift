import SwiftUI

struct InputFieldView<Content: View>: View {
    let title: String
    let showTitle: Bool
    let isOptionalTextView: Bool
    let isDividerShown: Bool?
    let isMandatoryField: Bool?
    
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            if showTitle {
                HStack(spacing: 2) {
                    Text(title)
                        .foregroundColor(Color.Blue.GREY)
                        .font(.regular(12))
                    
                    if isMandatoryField ?? false{
                        Text("*")
                            .foregroundColor(Color.Red.CORAL)
                            .font(.regular(12))
                    }
                    
                    Spacer()
                }
            }
            
            content
                .padding(.vertical, 15)
            
            if isDividerShown ?? false {
                Divider()
                    .frame(height: 1)
                    .foregroundColor(Color.Silver.TWO)
            }
        }
    }
}

// Preview
struct InputFieldView_Previews: PreviewProvider {
    static var previews: some View {
        InputFieldView(
            title: "Title",
            showTitle: true,
            isOptionalTextView: false,
            isDividerShown: true, isMandatoryField: true
        ) {
            Text("Custom Content")
                .foregroundColor(.blue)
        }
    }
}
