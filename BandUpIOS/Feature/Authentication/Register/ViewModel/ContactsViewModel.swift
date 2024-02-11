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
    
    @Published var phoneNumberCountryCode = ""
    @Published var phoneNumber = ""
    @Published var contactEmail = ""
    @Published var website = ""

    @Published var contactEmailState: TextFieldState = .neutral
    @Published var contactsWebsiteState: TextFieldState = .neutral
    
    private var cancellables = Set<AnyCancellable>()
    
    var next: (() -> Void)?

    var validateStep: Bool {
        let isAtLeastOneContactFieldNotEmpty = !contactEmail.isEmpty || !website.isEmpty || (!phoneNumber.isEmpty && !phoneNumberCountryCode.isEmpty)
        
        let isPhoneNumberValid = (phoneNumber.isEmpty && phoneNumberCountryCode.isEmpty) || (!phoneNumber.isEmpty && !phoneNumberCountryCode.isEmpty)
    
        return isAtLeastOneContactFieldNotEmpty && isPhoneNumberValid
    }
    
    init() {
        validateContactEmail.store(in: &cancellables)
        validateContactWebsite.store(in: &cancellables)
    }
    
    var validateContactEmail: AnyCancellable {
        $contactEmail
            .dropFirst()
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                if (try? self?.emailRegex.wholeMatch(in: email)) == nil {
                    withAnimation {
                        self?.contactEmailState = .invalid(errorMessage: "Please provide a valid email.")
                    }
                    return
                }
                self?.contactEmailState = .valid
            }
    }
    
    var validateContactWebsite: AnyCancellable {
        $website
            .dropFirst()
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [weak self] website in
                guard let url = URL(string: website) else {
                    withAnimation {
                        self?.contactsWebsiteState = .invalid(errorMessage: "Please provide a valid website URL.")
                    }
                    return
                }
                
                url.isReachable { success in
                    DispatchQueue.main.async {
                        withAnimation {
                            if success {
                                self?.contactsWebsiteState = .valid
                            } else {
                                self?.contactsWebsiteState = .invalid(errorMessage: "URL is unreachable")
                            }
                        }
                    }
                }
            }
    }
    
}
