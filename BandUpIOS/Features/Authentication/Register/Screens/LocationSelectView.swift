//
//  RegisterLocationSelectView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import SwiftUI
import MapKit

struct LocationSelectView: View {
    @ObservedObject var viewModel: LocationSelectViewModel
    
    var body: some View {
        VStack {
            Group {
                TextField("Country", text: $viewModel.country)
                    .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "mappin.and.ellipse"))
                TextField("City", text: $viewModel.city)
                    .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "building.2"))
                TextField("Zip-Code", text: $viewModel.zipcode)
                    .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "mail.and.text.magnifyingglass"))
            }
            .padding(.bottom, 8)

            Button {
                viewModel.register?()
            } label: {
                Text("Register")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ShrinkingButton())
            .disabled(!viewModel.validateStep)
        }
        .padding(.all)
    }
}

#Preview {
    LocationSelectView(viewModel: LocationSelectViewModel())
}
