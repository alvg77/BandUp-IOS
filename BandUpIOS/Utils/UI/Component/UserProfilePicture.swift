//
//  UserProfilePicture.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import SwiftUI

struct UserProfilePicture: View {
    @State var id = UUID()
    var imageURL: URL?
    let diameter: CGFloat
    
    init(imageKey: String?, diameter: CGFloat) {
        self.imageURL = imageKey != nil ? URL(string:"\(Secrets.s3BucketURL)/\(imageKey!)") : nil
        self.diameter = diameter
    }
    
    var body: some View {
        if let imageURL = imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: diameter, height: diameter)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: diameter, height: diameter)
                        .clipShape(Circle())
                case .failure(_):
                    Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                        .resizable()
                        .frame(width: diameter, height: diameter - 0.1 * diameter)
                        .onAppear {
                            self.id = UUID()
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .id(id)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: diameter, height: diameter)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    UserProfilePicture(imageKey: "dsafsdaf", diameter: 50)
}
