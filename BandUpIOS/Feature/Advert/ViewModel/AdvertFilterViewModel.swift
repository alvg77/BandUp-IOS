//
//  AdvertFilterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import Combine
import MapKit

class AdvertFilterViewModel: LocationService {
    @Published var filter: AdvertFilter
    @Published var availableGenres: [Genre]
    @Published var availableArtistTypes: [ArtistType]
    @Published var error: APIError?
    
    private var model: AdvertModel
    private var cancellables = Set<AnyCancellable>()
    private var filterExists: Bool
    
    var onComplete: (() -> Void)?
    var toAuth: (() -> Void)?
    
    init(model: AdvertModel) {
        self.model = model
        self.filter = model.advertFilter ?? AdvertFilter()
        self.filterExists = model.advertFilter != nil
        self.availableGenres = model.genres
        self.availableArtistTypes = model.artistTypes
        
        super.init()
        
        if let location = self.model.advertFilter?.location {
            self.mapItems.append(
                MKMapItem(
                    placemark: MKPlacemark(
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.lat,
                            longitude: location.lon
                        )
                    )
                )
            )
        }
        
        self.model.$genres.sink { [weak self] in
            self?.availableGenres = $0
        }.store(in: &cancellables)
        
        self.model.$artistTypes.sink { [weak self] in
            self?.availableArtistTypes = $0
        }.store(in: &cancellables)
        
        self.$mapItems.sink { [weak self] in
            guard let mapItem = $0.first else { return }
            self?.filter.location = Location(mapItem: mapItem)
        }.store(in: &cancellables)
    }
    
    var clearEnabled: Bool {
        filterExists
    }
    
    var applyEnabled: Bool {
        filter.location != nil ||
        !filter.genres.isEmpty ||
        !filter.searchedArtistTypes.isEmpty
    }
    
    func clearFilter() {
        model.applyFilter(advertFilter: nil, onComplete: onComplete ?? {}, handleError: handleError)
    }
    
    func applyFilter() {
        model.applyFilter(advertFilter: filter, onComplete: onComplete ?? {}, handleError: handleError)
    }
    
    func fetchGenresAndArtistTypes() {
        model.fetchGenresAndArtistTypes(handleError: handleError)
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
