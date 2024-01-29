//
//  RegisterView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 14.12.23.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    
    var body: some View {
        VStack {
            multistepIndicator
            step
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.step != .credentials)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.step != .credentials {
                    back
                }
            }
        }
        .alert("Registration Error", isPresented: $viewModel.registerErrorOccured) {
            Button ("OK", role: .cancel) {}
        } message: {
            Text(viewModel.registerError?.errorDescription ?? "An error occured while trying to process your registration request.")
        }
    }
}

private extension RegisterView {
    @ViewBuilder private var back: some View {
        Button {
            viewModel.goToPrev()
        } label: {
            Image(systemName: "chevron.left")
                .bold()
        }
    }
    
    @ViewBuilder private var multistepIndicator: some View {
        MultiStepIndicatorView(steps: $viewModel.steps, color: (.purple, .gray)) {
            Circle().frame(width: 8)
        }
    }
    
    @ViewBuilder private var step: some View {
        switch viewModel.step {
        case .credentials:
            CredentialsView(viewModel: viewModel.credentials)
        case .contacts:
            ContactsView(viewModel: viewModel.contacts)
        case .profileInfo:
            ProfileInfoView(viewModel: viewModel.profileInfo)
        case .genres:
            GenreSelectView(viewModel: viewModel.genreSelect)
        case .location:
            LocationSelectView(viewModel: viewModel.locationSelect)
        }
    }
}

#Preview {
    RegisterView(
        viewModel: RegisterViewModel()
    )
}
