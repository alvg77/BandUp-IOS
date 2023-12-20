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

            getStepView
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
        }
    }
    
    @ViewBuilder var back: some View {
        Button {
            viewModel.goToPrev()
        } label: {
            Image(systemName: "chevron.left")
                .bold()
        }
    }
    
    @ViewBuilder var multistepIndicator: some View {
        MultiStepIndicatorView(steps: $viewModel.steps, color: (.purple, .gray)) {
            Circle().frame(width: 8)
        }
    }
    
    @ViewBuilder var getStepView: some View {
        switch viewModel.step {
        case .credentials:
            CredentialsView(next: viewModel.goToNext, viewModel: viewModel.credentials)
        case .profileInfo:
            ProfileInfoView(next: viewModel.goToNext, viewModel: viewModel.profileInfo)
        case .genres:
            GenreSelectView(next: viewModel.goToNext, viewModel: viewModel.genreSelect)
        case .location:
            LocationSelectView(register: viewModel.register, viewModel: viewModel.locationSelect)
        }
    }
}

#Preview {
    RegisterView(
        viewModel: RegisterViewModel()
    )
}
