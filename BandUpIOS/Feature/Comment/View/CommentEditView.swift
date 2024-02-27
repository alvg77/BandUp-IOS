//
//  CommentUpdateView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 30.01.24.
//

import SwiftUI

struct CommentEditView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var editContent: String
    
    var commentId: Int
    
    var update: (Int, String) -> Void
    
    init(commentId: Int, content: String, edit: @escaping (Int, String) -> Void) {
        self.commentId = commentId
        self._editContent = State(initialValue: content)
        self.update = edit
    }
    
    var body: some View {
        NavigationStack {
            TextEditor(text: $editContent)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            update(commentId, editContent)
                            dismiss()
                        }
                        .disabled(editContent.isEmpty)
                    }
                }
                .navigationTitle("Edit Comment")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
