//
//  CommentPromptView.swift
//  MovieNight
//
//  Created by Boone on 5/9/25.
//

import SwiftUI

struct CommentPromptView: View {
    let averageColor: Color
    let comments: [Comment]
    var didTapSave: ((String) -> Void)? = nil

    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Comments")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            HStack(alignment: .bottom, spacing: 15) {
                ZStack(alignment: .leading) {
                    TextEditor(text: $text)
                        .frame(minHeight: 40)
                        .fixedSize(horizontal: false, vertical: true)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.gray)
                        }

                    if text.isEmpty {
                        Text("What'd you think?")
                            .font(.system(size: 14))
                            .foregroundStyle(.black.opacity(0.5))
                            .padding(.horizontal, 10)
                    }
                }

                if !text.isEmpty {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.white)
                        .offset(y: -10)
                        .onTapGesture {
                            didTapSave?(text)
                            text.removeAll()
                        }
                }
            }

            if !comments.isEmpty {
                VStack(spacing: 20) {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.2)
                        .foregroundStyle(.white)

                    ForEach(comments) { comment in
                        VStack(alignment: .leading) {
                            // TODO: Format Date
                            Text(comment.date?.description ?? "")
                                .foregroundStyle(.gray)
                                .font(.system(size: 12))

                            Text(comment.text ?? "")
                                .font(.system(size: 14))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(averageColor)
                                }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}

#Preview {
    CommentPromptView(averageColor: .red, comments: [])
}
