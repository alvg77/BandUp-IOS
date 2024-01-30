//
//  CreatePostView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import SwiftUI

struct CreateUpdatePostView: View {
    @ObservedObject var viewModel: CreateUpdatePostViewModel
    
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
                guard viewModel.flairs.isEmpty else { return }
                viewModel.getFlairs()
            }
            .refreshable {
                viewModel.getFlairs()
            }
        }
        .padding(.all, 8)
        .navigationTitle(viewModel.modifyAction == .create ? "Create Post" : "Edit Post")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            enableLinkButton
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                doneButton
            }
        }
    }
}

private extension CreateUpdatePostView {
    @ViewBuilder private var title: some View {
        TextField("Title", text: $viewModel.title)
            .font(.title2)
            .foregroundStyle(.purple)
            .bold()
            .padding(.bottom)
            .focused($focus, equals: .title)
    }
    
    @ViewBuilder private var postFlairPicker: some View {
        HStack {
            Text("Post Flair")
            Spacer()
            Picker("Post Flair", selection: $viewModel.flair) {
                Text("None").tag(Optional<PostFlair>(nil))
                ForEach(viewModel.flairs) {
                    Text($0.name).tag(Optional($0))
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color(.systemGray6)))
        .padding(.bottom, 8)
    }
  
    @ViewBuilder private var url: some View {
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
    
    @ViewBuilder private var enableLinkButton: some View {
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
    
    @ViewBuilder private var doneButton: some View {
        Button("Done") {
            viewModel.modify()
        }
        .disabled(!viewModel.validate)
    }
}
