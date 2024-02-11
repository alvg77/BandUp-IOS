//
//  UserDetailViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 7.02.24.
//

import Foundation
import Combine
import MapKit

class ProfileDetailViewModel: ObservableObject {
    var userId: Int?
    @Published var user: User?
    @Published var error: Error?
    @Published var loading: LoadingState = .notLoading
    
    private var cancellables = Set<AnyCancellable>()
    
    var navigateToProfileEdit: ((User, @escaping (User) -> Void) -> Void)?
    var toAuth: (() -> Void)?
    
    init(userId: Int? = nil) {
        self.userId = userId
    }
    
    func refreshUserDetails() {
        loading = .loading
        ProfileService.shared.fetchUser(id: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.loading = .notLoading
                case .failure(let error):
                    self?.loading = .notLoading
                    self?.handleError(error: error)
                }
            } receiveValue: { [weak self] in
                self?.user = $0
            }
            .store(in: &cancellables)
    }
    
    func editProfile() {
        guard let user = user else { return }
        navigateToProfileEdit?(user) { [weak self] in self?.user = $0 }
    }
    
    func deleteProfile() {
        loading = .loading
        guard let userId = user?.id else { return }
        ProfileService.shared.deleteProfile(id: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.loading = .notLoading
                    self?.toAuth?()
                case .failure(let error):
                    self?.loading = .notLoading
                    self?.handleError(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.logout()
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        do {
            try JWTService.shared.removeToken()
            toAuth?()
        } catch let error {
            self.error = error
        }
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
            return
        }
        self.error = error
    }
}
