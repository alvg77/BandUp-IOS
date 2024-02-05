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
            Text("Location")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 4)

            Text("In what city are you based?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            SearchBar(text: $viewModel.searchQuery, onSearchButtonClicked: viewModel.searchForCity)
            MapView(mapItems: viewModel.mapItems)
                .padding(.vertical)
            
            Button {
                viewModel.register?()
            } label: {
                Text("Register")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RoundButton())
            .disabled(!viewModel.validateStep)
        }
        .padding(.all)
    }
}

#Preview {
    LocationSelectView(viewModel: LocationSelectViewModel())
}
