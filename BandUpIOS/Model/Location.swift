//
//  Location.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 24.01.24.
//

import Foundation
import MapKit

struct Location: Codable {
    init(country: String?, city: String?, administrativeArea: String?, lat: Double, lon: Double) {
        self.country = country
        self.city = city
        self.administrativeArea = administrativeArea
        self.lat = lat
        self.lon = lon
    }
    
    init(mapItem: MKMapItem) {
        self.city = mapItem.placemark.locality
        self.administrativeArea = mapItem.placemark.administrativeArea
        self.country = mapItem.placemark.country
        self.lat = mapItem.placemark.coordinate.latitude
        self.lon = mapItem.placemark.coordinate.longitude
    }
    
    let country: String?
    let city: String?
    let administrativeArea: String?
    let lat: Double
    let lon: Double
}
