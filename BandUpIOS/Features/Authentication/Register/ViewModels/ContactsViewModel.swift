//
//  ContactsViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 3.01.24.
//

import Foundation
import Combine
import SwiftUI

class ContactsViewModel: ObservableObject {
    private let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

    var next: (() -> Void)?
    
    @Published var phoneNumber = ""
    @Published var contactEmail = ""
    @Published var website = ""
    
    @Published var contactEmailState: TextFieldState = .neutral
    
    var validateStep: Bool {
        !phoneNumber.isEmpty ||
        !contactEmail.isEmpty ||
        !website.isEmpty
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        validateContactEmail.store(in: &cancellables)
    }
    
    var validateContactEmail: AnyCancellable {
        $contactEmail
            .dropFirst()
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard (self?.contactEmail) != nil else {
                    return
                }
                if (try? self?.emailRegex.wholeMatch(in: email)) == nil {
                    withAnimation {
                        self?.contactEmailState = .invalid(errorMessage: "Please provide a valid email.")
                    }
                    return
                }
                self?.contactEmailState = .valid
            }
    }
    
}
