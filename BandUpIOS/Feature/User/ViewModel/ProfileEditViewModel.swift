//
//  UserUpdateViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 7.02.24.
//

import Foundation
import PhotosUI
import SwiftUI
import Combine

class ProfileEditViewModel: ObservableObject {
    var userId: Int
    @Published var username: String
    @Published var bio: String
    @Published var bioSheet = false
    @Published var genres: [Genre]
    @Published var artistType: ArtistType
    @Published var phoneNumberCountryCode: String
    @Published var phoneNumber: String
    @Published var contactEmail: String
    @Published var website: String
    @Published var profilePictureUIImage: UIImage?
    @Published var profilePicturePickerItem: PhotosPickerItem? {
        didSet {
            Task {
                if let data = try? await profilePicturePickerItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profilePictureUIImage = uiImage
                        }
                    }
                }
            }
        }
    } 
    @Published var availableArtistTypes: [ArtistType] = []
    @Published var availableGenres: [Genre] = []
    @Published var profilePictureKey: String?
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    private var cancellables = Set<AnyCancellable>()
    
    var onComplete: ((User) -> Void)?
    var toAuth: (() -> Void)?
    
    var validate: Bool {
        let isBasicInfoValid = !username.isEmpty && !bio.isEmpty && !genres.isEmpty
        
        let isContactInfoValid = validateContactInformation()
        
        return isBasicInfoValid && isContactInfoValid
    }
    
    init(user: User) {
        self.userId = user.id
        self.username = user.username
        self.profilePictureKey = user.profilePictureKey
        self.bio = user.bio
        self.genres = user.genres
        self.artistType = user.artistType
        self.contactEmail = user.contacts.contactEmail ?? ""
        self.website = user.contacts.website ?? ""
        self.phoneNumber = ""
        self.phoneNumberCountryCode = "" 
        
        if let phoneNumber = user.contacts.phoneNumber {
            let phoneNumberParts = phoneNumber.split(separator: " ")
            self.phoneNumber = phoneNumberParts[phoneNumberParts.endIndex - 1].description
            self.phoneNumberCountryCode = phoneNumberParts[phoneNumberParts.startIndex].description
        }
    }
    
    func editProfile() {
        loading = .loading
        guard let profilePictureUIImage = profilePictureUIImage else {
            editUserDetails()
            return
        }
        uploadImage(profilePictureUIImage: profilePictureUIImage)
    }
    
    private func editUserDetails() {
        ProfileService.shared.editProfile(
            id: userId,
            profileEditRequest:
                EditUser(
                    username: username,
                    profilePictureKey: profilePictureKey,
                    bio: bio,
                    genreIds: genres.map { $0.id },
                    artistTypeId: artistType.id,
                    contacts: Contacts(
                        phoneNumber: phoneNumber == "" ? nil : phoneNumberCountryCode + " " + phoneNumber,
                        contactEmail: contactEmail == "" ? nil : contactEmail,
                        website: website == "" ? nil : website
                    )
                )
        )
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
            self?.onComplete?($0)
        }
        .store(in: &cancellables)
    }
    
    private func uploadImage(profilePictureUIImage: UIImage) {
        profilePictureKey = "user/\(userId)/profile_main_\(Date.now.timeIntervalSince1970)"
        AWSS3Service.shared.fetchUploadSignedURL(objectKey: "\(profilePictureKey!)")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error: error)
                    self?.loading = .notLoading
                }
            } receiveValue: { [weak self] in
                self?.uploadWithPresignedURL(presignedURL: $0, profilePictureUIImage: profilePictureUIImage)
            }
            .store(in: &cancellables)
    }
    
    private func uploadWithPresignedURL(presignedURL: URL, profilePictureUIImage: UIImage) {
        AWSS3Service.shared.uploadImage(signedURL: presignedURL, image: profilePictureUIImage) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    self?.editUserDetails()
                case .failure(let error):
                    self?.error = error
                    self?.loading = .notLoading
                }
            }
        }
    }
    
    func fetchSelectionData() {
        loading = .loading
        GenreService.shared.getGenres()
            .combineLatest(ArtistTypeService.shared.getArtistTypes())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.loading = .notLoading
                case .failure(let error):
                    self?.loading = .notLoading
                    self?.handleError(error: error)
                }
            } receiveValue: { [weak self] (genres, artistTypes) in
                self?.availableGenres = genres
                self?.availableArtistTypes = artistTypes
            }
            .store(in: &cancellables)
    }
    
    private func validateContactInformation() -> Bool {
        let isAtLeastOneContactFieldNotEmpty = !contactEmail.isEmpty || !website.isEmpty || (!phoneNumber.isEmpty && !phoneNumberCountryCode.isEmpty)
        
        let isPhoneNumberValid = (phoneNumber.isEmpty && phoneNumberCountryCode.isEmpty) || (!phoneNumber.isEmpty && !phoneNumberCountryCode.isEmpty)
        
        return isAtLeastOneContactFieldNotEmpty && isPhoneNumberValid
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
            return
        }
        self.error = error
    }
}
