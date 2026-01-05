//
//  LeftAllignedHStack.swift
// ALNASR
//
//  Created by developer on 20/01/22.
//

import SwiftUI

struct LeftAlignedHStack<Content: View>: View {
    internal init(_ content: Content) {
        self.content = content
    }
    
    let content: Content

    var body: some View {
        HStack {
            content
            Spacer()
        }
    }
}

struct LeftAlignedHStack_Previews: PreviewProvider {
    static var previews: some View {
        LeftAlignedHStack(Text(""))
    }
}

