//
//  PhoneNumberTextField.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.02.24.
//

import SwiftUI

struct PhoneNumberTextField : View {
    private let cornerRadius: CGFloat = 15
    @Binding var countryCode: String
    @Binding var countryFlag: String
    @Binding var phoneNumber: String
    @State var countryCodeSheet = false
    @FocusState var focus: Bool
    
    var body: some View {
        HStack (spacing: 0) {
            Text("\(countryFlag) +\(countryCode)")
                .padding(.vertical)
                .padding(.horizontal, 8)
                .background(Color(.systemGray2))
                .cornerRadius(10)
                .foregroundColor(countryCode.isEmpty ? .secondary : .black)
                .onTapGesture {
                    countryCodeSheet.toggle()
                }
            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding(.vertical)
                .padding(.horizontal, 8)
        }
        .sheet(isPresented: $countryCodeSheet, content: {
            CountryCodes(countryCode: $countryCode, countryFlag: $countryFlag)
        })
    }
}
