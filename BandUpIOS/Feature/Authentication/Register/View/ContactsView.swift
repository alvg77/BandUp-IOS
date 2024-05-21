//
//  ContactsView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 2.01.24.
//

import SwiftUI

struct ContactsView: View {
    @ObservedObject var viewModel: ContactsViewModel
    @FocusState var focus: ContactsFocus?
    
    private let fieldBottomPadding: CGFloat = 8
    
    enum ContactsFocus {
        case phone
        case email
        case website
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Contacts")
                    .bold()
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 4)

                Text("Provide your contact information, so other members on the platform can reach to you.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                
                phoneNumberField
                contactEmailField
                websiteField
            }
            .padding(.bottom)
        
            continueButton
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
        .textInputAutocapitalization(.never)
    }
}

extension ContactsView {
    @ViewBuilder private var continueButton: some View {
        Button {
            if case .invalid(_) = viewModel.contactEmailState {
                viewModel.contactEmail = ""
            }
            viewModel.next()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(RoundButton())
        .disabled(!viewModel.validateStep)
    }
    
    @ViewBuilder private var phoneNumberField: some View {
        PhoneNumberTextField(countryCode: $viewModel.phoneNumberCountryCode, countryFlag: $viewModel.phoneNumberCountryFlag, phoneNumber: $viewModel.phoneNumber)
            .background(Color(.systemGray6))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(lineWidth: focus == .phone ? 4 : 2).foregroundStyle(.purple))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .focused($focus, equals: .phone)
        
        if case .invalid(let errorMessage) = viewModel.phoneNumberState, focus == .phone {
            FieldError(errorMessage: errorMessage)
                .transition(.slide)
        }
    }
    
    @ViewBuilder private var contactEmailField: some View {
        VStack {
            TextField("Contact Email", text: $viewModel.contactEmail)
                .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "at"))
                .padding(.top, fieldBottomPadding)
                .keyboardType(.emailAddress)
                .focused($focus, equals: .email)
                .autocorrectionDisabled()
                
            
            if case .invalid(let errorMessage) = viewModel.contactEmailState, focus == .email {
                FieldError(errorMessage: errorMessage)
                    .transition(.slide)
            }
        }
        .padding(.bottom, 8)

    }
    
    @ViewBuilder private var websiteField: some View {
        VStack {
            TextField("Websiste", text: $viewModel.website)
                .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "globe"))
                .focused($focus, equals: .website)
                .autocorrectionDisabled()
            
            if case .invalid(let errorMessage) = viewModel.contactsWebsiteState, focus == .website {
                FieldError(errorMessage: errorMessage)
                    .transition(.slide)
            }
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    ContactsView(viewModel: ContactsViewModel(next: {}))
}
