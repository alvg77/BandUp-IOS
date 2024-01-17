//
//  CreatePostView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import SwiftUI

struct ModifyPostView: View {
    @ObservedObject var viewModel: ModifyPostViewModel
    @FocusState var focus: ModifyPostViewField?
    
    enum ModifyPostViewField {
        case title
        case url
        case content
    }
    
    var body: some View {
        VStack {
            ScrollView {
                if let errorMessage = viewModel.error?.errorDescription {
                    ErrorMessage(errorMessage: errorMessage)
                }
                
                title
                postFlairPicker
                url
                
                CharacterCountTextEditor("Content", text: $viewModel.content, maxChars: viewModel.maxContentLength)
                    .focused($focus, equals: .content)
            }
            .task {
                viewModel.getFlairs()
            }
            .refreshable {
                viewModel.getFlairs()
            }
        }
        .padding(.all, 8)
        .navigationTitle("Create New Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button ("Create") {
                    viewModel.createPost()
                }
                .buttonStyle(RoundButton())
                .disabled(!viewModel.validate)
            }
        }
        .safeAreaInset(edge: .bottom) {
            enableLinkButton
        }
    }
}

extension ModifyPostView {
    @ViewBuilder var title: some View {
        TextField("Title", text: $viewModel.title)
            .font(.title2)
            .foregroundStyle(.purple)
            .bold()
            .padding(.bottom)
            .focused($focus, equals: .title)
    }
    
    @ViewBuilder var postFlairPicker: some View {
        Picker("Post Flair", selection: $viewModel.flair) {
            Text("None").tag(Optional<PostFlair>(nil))
            ForEach(viewModel.flairs) {
                Text($0.name).tag(Optional($0))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color(.systemGray6)))
        .pickerStyle(.navigationLink)
        .padding(.bottom, 8)
    }
  
    @ViewBuilder var url: some View {
        if viewModel.urlEnabled {
            VStack {
                HStack {
                    Image(systemName: "link")
                        .foregroundStyle(.purple)
                        .bold()
                    TextField("URL", text: $viewModel.url)
                        .focused($focus, equals: .url)
                        .textInputAutocapitalization(.never)
                }
                .padding(.bottom, 8)
                
                if case .invalid(let errorMessage) = viewModel.urlState {
                    FieldError(errorMessage: errorMessage)
                }
            }
        }
    }
    
    @ViewBuilder var enableLinkButton: some View {
        HStack {
            Button {
                viewModel.enableLink()
            } label: {
                Image(systemName: "link")
                    .padding(.all, 8)
                    .foregroundStyle(viewModel.urlEnabled ? .white : .purple)
                    .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(viewModel.urlEnabled ? .purple : .clear))
                    .font(.title3)
                    .fontWeight(.heavy)
            }
            
            Spacer()
            
            Button("Done") {
                focus = nil
            }
            .opacity(focus == nil ? 0 : 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        ModifyPostView(viewModel: ModifyPostViewModel(toPost: { _ in }))
    }
}
