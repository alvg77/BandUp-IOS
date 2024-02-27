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
    @Published var loading: LoadingState = .notLoading
    @Published var availableGenres: [Genre]
    @Published var availableArtistTypes: [ArtistType]
    @Published var error: APIError?
    
    private var store: AdvertStore
    private var cancellables = Set<AnyCancellable>()
    private var filterExists: Bool
    
    private let onSuccess: () -> Void
    
    var clearEnabled: Bool {
        filterExists
    }
    
    var applyEnabled: Bool {
        filter.location != nil ||
        !filter.genres.isEmpty ||
        !filter.searchedArtistTypes.isEmpty
    }
    
    var observeGenresChanges: AnyCancellable {
        self.store.$genres.sink { [weak self] in
            self?.availableGenres = $0
        }
    }
    
    var observeArtistTypesChanges: AnyCancellable {
        self.store.$artistTypes.sink { [weak self] in
            self?.availableArtistTypes = $0
        }
    }
    
    var observeLocationChanges: AnyCancellable {
        self.$mapItems.sink { [weak self] in
            guard let mapItem = $0.first else { return }
            self?.filter.location = Location(mapItem: mapItem)
        }
    }
    
    init(
        store: AdvertStore,
        onSuccess: @escaping () -> Void
    ) {
        self.store = store
        self.onSuccess = onSuccess
        self.filter = store.advertFilter ?? AdvertFilter()
        self.filterExists = store.advertFilter != nil
        self.availableGenres = store.genres
        self.availableArtistTypes = store.artistTypes
        super.init()
        if let location = self.store.advertFilter?.location {
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
        observeGenresChanges.store(in: &cancellables)
        observeArtistTypesChanges.store(in: &cancellables)
        observeLocationChanges.store(in: &cancellables)
    }
    
    func clearFilter() {
        loading = .loading
        store.applyFilter(
            advertFilter: nil,
            onSuccess: { [weak self] in
                self?.loading = .notLoading
                self?.onSuccess()
            },
            handleError: handleError
        )
    }

    func applyFilter() {
        loading = .loading
        store.applyFilter(
            advertFilter: filter,
            onSuccess: { [weak self] in
                self?.loading = .notLoading
                self?.onSuccess()
            },
            handleError: handleError
        )
    }

    func fetchGenresAndArtistTypes() {
        loading = .loading
        store.fetchGenresAndArtistTypes(onSuccess: { [weak self] in self?.loading = .notLoading }, handleError: handleError)
    }
    
    private func handleError(error: APIError?) {
        self.loading = .notLoading
        self.error = error
    }
}
