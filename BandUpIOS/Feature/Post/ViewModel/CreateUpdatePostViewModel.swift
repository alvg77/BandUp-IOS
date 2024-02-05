//
//  CreatePostViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import Foundation
import SwiftUI
import Combine

class CreateUpdatePostViewModel: ObservableObject {
    let postId: Int?
    
    @Published var title = ""
    @Published var content = ""
    @Published var url = ""
    @Published var urlEnabled = false
    @Published var flair: PostFlair?
    @Published var urlState = TextFieldState.neutral
    @Published var flairs: [PostFlair] = []
    
    @Published var error: APIError?
    
    let modifyAction: ModifyAction
    let maxContentLength = 5000
    
    private var model: PostModel
    private var cancellables = Set<AnyCancellable>()
    
    var onCreate: (() -> Void)? = nil
    var onUpdate: ((Post) -> Void)? = nil
    var toAuth: (() -> Void)? = nil

    init(model: PostModel) {
        self.postId = nil
        self.modifyAction = .create
        self.model = model
        
        self.model.$flairs.sink { [weak self] in
            self?.flairs = $0
        }.store(in: &cancellables)
        
        checkURLValidity.store(in: &cancellables)
    }
    
    init(post: Post, model: PostModel) {
        self.postId = post.id
        self.modifyAction = .update
        self.title = post.title
        self.content = post.content
        if let url = post.url {
            self.url = url
            self.urlEnabled = true
        }
        self.flair = post.flair
        self.model = model
        
        self.model.$flairs.sink { [weak self] in
            self?.flairs = $0
        }.store(in: &cancellables)
        
        checkURLValidity.store(in: &cancellables)
    }
    
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
    
    func enableLink() {
        withAnimation {
            urlEnabled.toggle()
        }
    }
    
    func getFlairs() {
        model.fetchFlairs(handleError: handleError)
    }
    
    func modify() {
        switch modifyAction {
        case .create:
            createPost()
        case .update:
            updatePost()
        }
    }

    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
            return
        }
        self.error = error
    }
    
    private func createPost() {
        model.createPost(
            CreateUpdatePost(title: title, url: urlEnabled ? url : nil, content: content, flairId: flair!.id),
            onSuccess: onCreate ?? {},
            handleError: handleError
        )
    }
    
    private func updatePost() {
        model.updatePost(
            CreateUpdatePost(title: title, url: urlEnabled ? url : nil, content: content, flairId: flair!.id),
            id: postId!,
            onSuccess: onUpdate ?? { _ in },
            handleError: handleError
        )
    }
}
