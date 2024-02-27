//
//  LocationText.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.02.24.
//

import SwiftUI

struct LocationText: View {
    let location: Location
    
    var body: some View {
        HStack {
            Image(systemName: "mappin")
            Text("\(location.city ?? ""), \(location.administrativeArea ?? ""), \(location.country ?? "")")
        }
        .font(.subheadline)
        .foregroundStyle(.gray)
    }
}

#Preview {
    LocationText(location: Location(country: "Country", city: "City", administrativeArea: "Area", lat: 0, lon: 0))
}
