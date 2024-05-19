//
//  CommentRowView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import SwiftUI

struct CommentRowView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var editing = false
    
    var commentId: Int
    var content: String
    var createdAt: Date
    var creator: UserDetails
    
    var edit: (Int, String) -> Void
    var delete: (Int) -> Void
    
    init(
        commentId: Int,
        content: String,
        createdAt: Date,
        creator: UserDetails,
        edit: @escaping (Int, String) -> Void,
        delete: @escaping (Int) -> Void
    ) {
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.creator = creator
        self.edit = edit
        self.delete = delete
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            commentCreator
            commentContent
                .multilineTextAlignment(.leading)
        }
        .cardBackground()
        .sheet(isPresented: $editing) {
            CommentEditView(commentId: commentId, content: content, edit: edit)
        }
    }
}

private extension CommentRowView {
    @ViewBuilder var commentContent: some View {
        Text(content)
    }
    
    @ViewBuilder var commentCreator: some View {
        HStack {
            userDetails
            
            Spacer()
            
            if creator.email == JWTService.shared.extractEmail() {
                menu
            }
        }
    }
    
    @ViewBuilder var userDetails: some View {
        UserProfilePicture(imageKey: creator.profilePictureKey, diameter: 35)
        VStack (alignment: .leading) {
            Text(creator.username).font(.caption).bold()
            Text(createdAt.formatted())
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }
    
    @ViewBuilder var menu: some View {
        Menu {
            Button("Delete", role: .destructive) { delete(commentId) }
            Button("Edit") { editing.toggle() }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
}

#Preview {
    CommentRowView(commentId: 0, content: "Comment comment comment comment", createdAt: Date.now, creator: UserDetails(id: 0, username: "Username", email: "username@email.com"), edit: {_,_ in}, delete: {_ in})
}
