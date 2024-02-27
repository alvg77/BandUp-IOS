//
//  MapView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 3.02.24.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    var mapItems: [MKMapItem]

    var body: some View {
        Map(coordinateRegion: .constant(getCoordinateRegion()),
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: .none,
            annotationItems: mapItems) { mapItem in
            MapMarker(coordinate: mapItem.placemark.coordinate, tint: .purple)
        }

    }

    private func getCoordinateRegion() -> MKCoordinateRegion {
        if let firstMapItem = mapItems.first {
            return MKCoordinateRegion(center: firstMapItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        } else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
        }
    }
}
