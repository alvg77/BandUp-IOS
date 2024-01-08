//
//  LoginView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        ScrollView {
            Text("Discover your next musical adventure!")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            if let error = viewModel.error {
                ErrorMessage(errorMessage: error.errorDescription ?? "An error occured while trying to process your login request.")
                    .padding(.bottom)
            }
            
            emailField
                .padding(.bottom, 8)
            passwordField
                .padding(.bottom)
            loginButton
            
            VStack (alignment: .center) {
                Text("Don't have an account?")
                    .font(.subheadline)
                    .padding(.top)
                createAccountButton
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
        }
        .scrollIndicators(.never)
        .padding(.horizontal, 8)
        .textInputAutocapitalization(.never)
        .navigationTitle("Login")
    }
}

private extension LoginView {
    @ViewBuilder var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "at"))
    }
    
    @ViewBuilder var passwordField: some View {
        SecureField("Password", text: $viewModel.password)
            .textFieldStyle(RoundBorderTextFieldStyle(sfSymbol: "lock"))
    }
    
    
    @ViewBuilder var loginButton: some View {
        Button {
            viewModel.login()
        } label: {
            HStack {
                Text("Login")
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .disabled(!viewModel.verifyInput)
        .buttonStyle(RoundButton())
    }
    
    @ViewBuilder var createAccountButton: some View {
        Button("Create account") {
            viewModel.toRegisterTapped?()
        }
        .foregroundStyle(.purple)
        .font(.headline)
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(authenticate: { }, toRegister: {}))
}
