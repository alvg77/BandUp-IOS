//
//  SwiftUIView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 7.02.24.
//

import SwiftUI

enum ImageShape {
    case circle
    case rectagnle
}

struct AWSImage: View {
    let imageURL: URL
    let shape: ImageShape
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .clipShape(shape == .circle ? AnyShape(Circle()) : AnyShape(Rectangle()))
            case .failure(let error):
                Text("Failed to load image: \(error.localizedDescription)")
            @unknown default:
                EmptyView()
            }
        }
    }
}
