//
//  LocationService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 3.02.24.
//

import Foundation
import MapKit

class LocationService: ObservableObject {
    @Published var searchQuery = ""
    @Published var mapItems: [MKMapItem] = []
    
    func searchForCity() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery

        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                }
                return
            }
            
            let cityItems = response.mapItems.filter { item in
                return item.placemark.administrativeArea != nil
            }
            
            self.mapItems = cityItems
        }
    }
    
    func getLocation() -> Location? {
        guard let mapItem = mapItems.first else {
            return nil
        }

        return Location(
            mapItem: mapItem
        )
    }
}
