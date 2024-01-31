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
    
    var update: (Int, String) -> Void
    var delete: (Int) -> Void
    
    init(
        commentId: Int,
        content: String,
        createdAt: Date,
        creator: UserDetails,
        update: @escaping (Int, String) -> Void,
        delete: @escaping (Int) -> Void
    ) {
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.creator = creator
        self.update = update
        self.delete = delete
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            commentCreator
            commentContent
                .multilineTextAlignment(.leading)
        }
        .padding(.all, 15)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 2, x: 0, y: 1)
        .padding(.vertical, 2)
        .sheet(isPresented: $editing) {
            CommentUpdateView(commentId: commentId, content: content, update: update)
        }
        .padding(.all, 2)

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
        Image(systemName: "person.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.all, 4)
            .background(.purple)
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
    CommentRowView(commentId: 0, content: "Comment comment comment comment", createdAt: Date.now, creator: UserDetails(id: 0, username: "Username", email: "username@email.com"), update: {_,_ in}, delete: {_ in})
}
