//
//  AuthView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 18.01.24.
//

import SwiftUI

struct AuthView: View {
    var navigateToLogin: (() -> Void)?
    var navigateToRegister: (() -> Void)?
    
    var body: some View {
        VStack {
            Text("BandUP")
                .font(.title)
                .fontWeight(.black)
            Text("Discover your next musical adventure")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundStyle(.purple)
            image
                .padding(.vertical, 32)
            loginButton
                .padding(.bottom, 8)
            registerButton
        }
        .padding(.all, 8)
    }
}

private extension AuthView {
    @ViewBuilder private var image: some View {
        Image("auth")
            .resizable()
            .scaledToFit()
    }
    
    @ViewBuilder private var loginButton: some View {
        Button {
            navigateToLogin?()
        } label: {
            Text("Log In")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(RoundButton())
    }
    
    @ViewBuilder var registerButton: some View {
        Button {
            navigateToRegister?()
        } label: {
            Text("Register")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(RoundButton())
    }
}

#Preview {
    AuthView()
}
