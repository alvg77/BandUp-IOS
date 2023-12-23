//
//  RegisterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct CredentialsView: View {
    @ObservedObject var viewModel: CredentialsViewModel
    
    private let fieldBottomPadding: CGFloat = 8
    
    var body: some View {
        ScrollView {
            VStack {
                if let error = viewModel.error {
                    ErrorMessage(errorMessage: error.errorDescription ?? "An error occured while trying to verify your username and email availability.")
                }
                usernameField
                emailField
                passwordField
            }
            .padding(.bottom)
        
            continueButton
        }
        .padding(.all)
        .textInputAutocapitalization(.never)
    }
    
    @ViewBuilder var continueButton: some View {
        Button {
            viewModel.checkCredentialsAvailability()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ShrinkingButton())
        .disabled(!viewModel.validateStep)
    }
    
    func showError(errorMessage: String) -> some View {
        Text(errorMessage)
            .font(.caption)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.push(from: .top))
            .padding(.leading)
    }
    
    @ViewBuilder var usernameField: some View {
        TextField("Username", text: $viewModel.username)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "person"))
            .padding(.top, fieldBottomPadding)
        
        if case .invalid(let errorMessage) = viewModel.usernameState {
            showError(errorMessage: errorMessage)
        }
        
        if viewModel.usernameAvailable == .taken {
            showError(errorMessage: "Username already exists.")
        }
    }
    
    @ViewBuilder var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "at"))
            .padding(.top, fieldBottomPadding)
            .keyboardType(.emailAddress)
        
        if case .invalid(let errorMessage) = viewModel.emailState {
            showError(errorMessage: errorMessage)
        }
        
        if viewModel.emailAvailable == .taken {
            showError(errorMessage: "Email already exitsts.")
        }
    }
    
    @ViewBuilder var passwordField: some View {
        TextField("Password", text: $viewModel.password)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "lock"))
            .padding(.top, fieldBottomPadding)
        
        if case .invalid(let errorMessage) = viewModel.passwordState {
            showError(errorMessage: errorMessage)
        }
    }
}

#Preview {
    CredentialsView(viewModel: CredentialsViewModel())
}
