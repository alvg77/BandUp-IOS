//
//  CreatePostViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import Foundation
import SwiftUI
import Combine

class ModifyPostViewModel: ObservableObject {
    @Published var title = ""
    let maxContentLength = 5000
    @Published var content = ""
    @Published var url = ""
    @Published var urlEnabled = false
    @Published var flair: PostFlair?
    @Published var urlState = TextFieldState.neutral
    
    @Published var flairs = [PostFlair]()
    @Published var error: APIError?
    
    private let toPost: ((Post) -> Void)?
    
    var validate: Bool {
        !title.isEmpty &&
        !title.isEmpty && title.count <= maxContentLength &&
        ((urlEnabled && !url.isEmpty) || !urlEnabled) &&
        flair != nil
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(toPost: ((Post) -> Void)?) {
        self.toPost = toPost
        checkURLValidity.store(in: &cancellables)
    }

    init(post: Post, toPost: ((Post) -> Void)?) {
        self.title = post.title
        self.content = post.content
        if let url = post.url {
            self.url = url
            self.urlEnabled = true
        }
        self.flair = post.flair
        self.toPost = toPost
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
        PostFlairService.shared.getPostFlairs { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let flairs):
                    self?.flairs = flairs
                    self?.error = nil
                case .failure(let error):
                    withAnimation {
                        self?.error = error
                    }
                }
            }
        }
    }
    
    func createPost() {
        PostService.shared.create(postCreateRequest: ModifyPost(title: title, url: url, content: content, flairId: flair!.id)) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let post):
                    self?.error = nil
                    self?.toPost?(post)
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
