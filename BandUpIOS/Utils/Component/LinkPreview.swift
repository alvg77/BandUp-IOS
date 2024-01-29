//
//  LinkPreview.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 16.01.24.
//

import SwiftUI
import LinkPresentation

struct LinkView: UIViewRepresentable {
    var metadata: LPLinkMetadata
    
    func makeUIView(context: Context) -> some UIView {
        let linkView = LPLinkView(metadata: metadata)
        return linkView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

struct LinkPreview: View {
    @State private var metadata: LPLinkMetadata?
    @State private var isLoading = true
    let url: URL?

    func fetchMetadata() async {
        guard let url else {
            self.isLoading = false
            return
        }
        do {
            let provider = LPMetadataProvider()
            let metadata = try await provider.startFetchingMetadata(for: url)
            self.metadata = metadata
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let metadata = metadata {
                LinkView(metadata: metadata)
            } else {
                VStack(alignment: .center) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    Text("Unable to load preview")
                }
            }
        }
        .task {
            await self.fetchMetadata()
        }
    }
}
