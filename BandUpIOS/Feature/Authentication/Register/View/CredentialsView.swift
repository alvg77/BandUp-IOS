//
//  RegisterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct CredentialsView: View {
    @ObservedObject var viewModel: CredentialsViewModel
    @FocusState var focus: CredentialsFocus?

    enum CredentialsFocus {
        case username
        case email
        case password
    }
    
    private let fieldBottomPadding: CGFloat = 8
        
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text("Credentials")
                        .bold()
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.all, 4)
                    
                    Text("You will need these to later log into your account.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                    
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
            
            if viewModel.loading == .loading {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
        .textInputAutocapitalization(.never)
    }
}

private extension CredentialsView {
    @ViewBuilder private var continueButton: some View {
        Button {
            viewModel.checkCredentialsAvailability()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(RoundButton())
        .disabled(!viewModel.validateStep)
    }
    
    @ViewBuilder private var usernameField: some View {
        TextField("Username", text: $viewModel.username)
            .focused($focus, equals: .username)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "person"))
            .padding(.top, fieldBottomPadding)
            .autocorrectionDisabled()
        
        if case .invalid(let errorMessage) = viewModel.usernameState, focus == .username {
            FieldError(errorMessage: errorMessage)
        }
        
        if viewModel.usernameAvailable == .taken {
            FieldError(errorMessage: "Username already exists.")
        }
    }
    
    @ViewBuilder private var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .focused($focus, equals: .email)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "at"))
            .padding(.top, fieldBottomPadding)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
        
        if case .invalid(let errorMessage) = viewModel.emailState, focus == .email {
            FieldError(errorMessage: errorMessage)
        }
        
        if viewModel.emailAvailable == .taken {
            FieldError(errorMessage: "Email already exitsts.")
        }
    }
    
    @ViewBuilder private var passwordField: some View {
        SecureField("Password", text: $viewModel.password)
            .focused($focus, equals: .password)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "lock"))
            .padding(.top, fieldBottomPadding)
            .autocorrectionDisabled()
        
        if case .invalid(let errorMessage) = viewModel.passwordState, focus == .password {
            FieldError(errorMessage: errorMessage)
        }
    }
}

#Preview {
    CredentialsView(viewModel: CredentialsViewModel(next: {}))
}
