//
//  FlowList\.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI
import Flow

struct FlowList<Data: CustomStringConvertible & Identifiable>: View {
    let data: [Data]
    
    var body: some View {
        HFlow {
            ForEach(data) { element in
                Text(element.description)
                    .font(.caption)
                    .bold()
                    .padding(.all, 6)
                    .foregroundStyle(.white)
                    .background(.purple)
                    .clipShape(Capsule())
            }
        }
    }
}
