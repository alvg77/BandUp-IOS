//
//  CreatePostViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import Foundation
import SwiftUI
import Combine

class PostCreateEditViewModel: ObservableObject {
    let postId: Int?
    @Published var title = ""
    @Published var content = ""
    @Published var url = ""
    @Published var urlEnabled = false
    @Published var flair: PostFlair?
    @Published var urlState = TextFieldState.neutral
    @Published var flairs: [PostFlair] = []
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    let modifyAction: ModifyAction
    let maxContentLength = 5000
    
    private var store: PostStore
    private var cancellables = Set<AnyCancellable>()
    
    private let onSuccess: () -> Void

    var validate: Bool {
        !title.isEmpty &&
        !content.isEmpty && content.count <= maxContentLength &&
        ((urlEnabled && !url.isEmpty) || !urlEnabled) &&
        flair != nil
    }
    
    var checkURLValidity: AnyCancellable {
        $url.debounce(for: 0.8, scheduler: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] url in
                if self?.urlEnabled == false {
                    self?.urlState = .valid
                }
                
                let url = URL(string: url)
                guard let url = url else {
                    withAnimation {
                        self?.urlState = .invalid(errorMessage: "Cannot validate URL")
                    }
                    return
                }
                
                url.isReachable { success in
                    DispatchQueue.main.async {
                        withAnimation {
                            if success {
                                self?.urlState = .valid
                            } else {
                                self?.urlState = .invalid(errorMessage: "URL is unreachable")
                            }
                        }
                    }
                }
            }
    }
    
    var observeFlairsChanges: AnyCancellable {
        self.store.$flairs.sink { [weak self] in
            self?.flairs = $0
        }
    }
    
    init(
        store: PostStore,
        onSuccess: @escaping () -> Void
    ) {
        self.store = store
        self.onSuccess = onSuccess
        self.postId = nil
        self.modifyAction = .create
        self.flairs = self.store.flairs
        observeFlairsChanges.store(in: &cancellables)
        checkURLValidity.store(in: &cancellables)
    }
    
    init(
        post: Post,
        store: PostStore,
        onSuccess: @escaping () -> Void
    ) {
        self.store = store
        self.onSuccess = onSuccess
        self.postId = post.id
        self.modifyAction = .edit
        self.title = post.title
        self.content = post.content
        if let url = post.url {
            self.url = url
            self.urlEnabled = true
        }
        self.flair = post.flair
        self.flairs = self.store.flairs
        observeFlairsChanges.store(in: &cancellables)
        checkURLValidity.store(in: &cancellables)
    }
    
    func enableLink() {
        withAnimation {
            urlEnabled.toggle()
        }
    }
    
    func getFlairs() {
        loading = .loading
        store.fetchFlairs(onSuccess: { [weak self] in self?.loading = .notLoading }, handleError: handleError)
    }
    
    func modify() {
        loading = .loading
        switch modifyAction {
        case .create:
            createPost()
        case .edit:
            editPost()
        }
    }

    private func handleError(error: APIError?) {
        self.loading = .notLoading
        self.error = error
    }
    
    private func createPost() {
        store.createPost(
            CreateEditPost(title: title, url: urlEnabled ? url : nil, content: content, flairId: flair!.id), 
            onSuccess: { [weak self] in
                self?.loading = .notLoading
                self?.onSuccess()
            },
            handleError: handleError
        )
    }
    
    private func editPost() {
        store.editPost(
            CreateEditPost(title: title, url: urlEnabled ? url : nil, content: content, flairId: flair!.id),
            id: postId!,
            onSuccess: { [weak self] in
                self?.loading = .notLoading
                self?.onSuccess()
            },
            handleError: handleError
        )
    }
}
