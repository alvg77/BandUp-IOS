//
//  ContactsList.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.02.24.
//

import SwiftUI

struct ContactsList: View {
    let contacts: Contacts
    
    var body: some View {
        VStack (alignment: .leading) {
            if let email = contacts.contactEmail {
                HStack {
                    Image(systemName: "envelope").foregroundStyle(.purple).bold()
                    Text(email)
                }.bold()
            }
            
            if let number = contacts.phoneNumber {
                HStack {
                    Image(systemName: "phone").foregroundStyle(.purple)
                    Text("+\(number)")
                }.bold()
            }
            
            if let website = contacts.website {
                HStack {
                    Image(systemName: "globe").foregroundStyle(.purple)
                    Text(website)
                }.bold()
            }
        }
    }
}

#Preview {
    ContactsList(contacts: Contacts(phoneNumber: "+3594944949", contactEmail: "email@email.email", website: "website.com"))
}
