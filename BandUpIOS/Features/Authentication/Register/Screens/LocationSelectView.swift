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
        ScrollView {
            Text("Location")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("In what city are you based?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            // later to be changed
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
            .buttonStyle(RoundButton())
            .disabled(!viewModel.validateStep)
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
    }
}

#Preview {
    LocationSelectView(viewModel: LocationSelectViewModel())
}
