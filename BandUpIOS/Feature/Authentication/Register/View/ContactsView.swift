//
//  ContactsView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 2.01.24.
//

import SwiftUI
import iPhoneNumberField

struct ContactsView: View {
    @ObservedObject var viewModel: ContactsViewModel
    @FocusState var phoneNumberFocus: Bool
    
    private let fieldBottomPadding: CGFloat = 8
    
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
            viewModel.next?()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(RoundButton())
        .disabled(!viewModel.validateStep)
    }
    
    @ViewBuilder private var phoneNumberField: some View {
        iPhoneNumberField("Phone Number", text: $viewModel.phoneNumber)
            .flagHidden(false)
            .flagSelectable(true)
            .maximumDigits(15)
            .clearButtonMode(.whileEditing)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .overlay(RoundedRectangle(cornerRadius: 15)
            .stroke(lineWidth: phoneNumberFocus ? 4 : 2)
            .foregroundStyle(.purple))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .focused($phoneNumberFocus)
    }
    
    @ViewBuilder private var contactEmailField: some View {
        VStack {
            TextField("Contact Email", text: $viewModel.contactEmail)
                .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "at"))
                .padding(.top, fieldBottomPadding)
                .keyboardType(.emailAddress)
            
            if case .invalid(let errorMessage) = viewModel.contactEmailState {
                FieldError(errorMessage: errorMessage)
            }
        }
        .padding(.bottom, 8)

    }
    
    @ViewBuilder private var websiteField: some View {
        VStack {
            TextField("Websiste", text: $viewModel.website)
                .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "globe"))

            if case .invalid(let errorMessage) = viewModel.contactsWebsiteState {
                FieldError(errorMessage: errorMessage)
            }
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    ContactsView(viewModel: ContactsViewModel())
}
