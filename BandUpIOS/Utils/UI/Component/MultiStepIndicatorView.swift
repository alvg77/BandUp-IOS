//
//  MultiStepView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

extension CaseIterable where Self: Equatable {
    var allCases: AllCases { Self.allCases }
    
    func next() -> Self {
        let index = allCases.firstIndex(of: self)!
        let next = allCases.index(after: index)
        guard next != allCases.endIndex else { return allCases[index] }
        return allCases[next]
    }
    
    func previous() -> Self {
        let index = allCases.firstIndex(of: self)!
        let previous = allCases.index(index, offsetBy: -1)
        guard previous >= allCases.startIndex else { return allCases[index] }
        return allCases[previous]
    }
    
    static var allValues: Self.AllCases {
        return allCases
    }
}

struct MultiStepIndicatorView<T: CaseIterable, Content: View>: View {
    @Binding var steps: [T]
    let color: (Color, Color)
    @ViewBuilder let content: () -> Content
    
    @State var numberOfSteps: Int = 0
    @State var widthOfLastItem = 0.0
    @State var images: [UIImage] = []
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<numberOfSteps, id: \.self) { index in
                    HStack {
                        VStack(spacing: 0) {
                            content().foregroundStyle(index < steps.count ? color.0 : color.1)
                        }
                    }
                }
            }
        }.onAppear() {
            numberOfSteps = type(of: steps).Element.self.allCases.count
        }
    }
}
