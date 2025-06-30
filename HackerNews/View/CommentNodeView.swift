//
//  CommentNodeView.swift
//  HN Reader
//
//  Created by Michael Hsieh on 6/28/25.
//

import SwiftUI

struct CommentNodeView: View {
    @ObservedObject var node: CommentNode
    @ObservedObject var model: CommentsViewModel
    var depth: Int

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            if depth > 0 {
                VStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1)
                        .padding(.top, 4)
                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(node.comment.author) • \(node.comment.date.timeAgo)")
                        .font(.callout)
                        .foregroundColor(.gray)

                    Spacer()

                    if !node.comment.kids.isEmpty {
                        Button {
                            if node.isExpanded {
                                node.isExpanded = false
                            } else {
                                if node.children.isEmpty {
                                    model.fetchChildComments(for: node)
                                }
                                node.isExpanded = true
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                                if !node.isExpanded {
                                    Text("\(node.comment.kids.count)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }

                // Wrap comment HTML in full HTML doc with CSS and viewport meta
                let styledHTML = """
                <html>
                <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                  body, p, span, div, li {
                    font-size: 18px !important;
                    line-height: 1.6 !important;
                    margin: 0 !important;
                    padding: 0 !important;
                  }
                  h1, h2, h3, h4, h5, h6 {
                    font-size: 18px !important;
                    font-weight: normal !important;
                  }
                </style>
                </head>
                <body>
                \(node.comment.text)
                </body>
                </html>
                """

                HTMLStringView(htmlContent: styledHTML)
                    .frame(minHeight: 50)
                    .padding(.leading, CGFloat(depth) * 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if node.isExpanded {
                    ForEach(node.children, id: \.id) { childNode in
                        CommentNodeView(node: childNode, model: model, depth: depth + 1)
                    }
                }
            }
        }
        .padding(.bottom, 12)
        //        .frame(minHeight: 120)
    }
}
