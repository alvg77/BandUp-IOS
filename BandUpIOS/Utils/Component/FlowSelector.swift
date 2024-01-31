//
//  LocationSelect.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import SwiftUI
import Flow

struct FlowSelector<Data: CustomStringConvertible & Identifiable>: View {
    let data: [Data]
    @Binding var selected: [Data]
    
    var body: some View {
        ScrollView {
            VFlow (alignment: .leading) {
                ForEach(data) { element in
                    Button {
                        guard let index = selected.firstIndex(where: {$0.id == element.id}) else {
                            selected.append(element)
                            return
                        }
                        selected.remove(at: index)
                    } label: {
                        Text(element.description)
                            .fontWeight(.bold)
                            .font(.subheadline)
                            .foregroundStyle(selected.contains(where: { $0.id == element.id }) ? .white : .accentColor)
                            .padding(.all)
                            .background(selected.contains(where: {$0.id == element.id}) ? .purple : Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
