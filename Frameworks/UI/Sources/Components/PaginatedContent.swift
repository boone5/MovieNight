//
//  PaginatedContent.swift
//  UI
//
//  Created by Ayren King on 12/7/25.
//

import Foundation
import SwiftUI

/// A container-agnostic pagination helper that emits your row views and
/// calls `onLoadMore` when the last item scrolls into view.
///
/// This view does not wrap its content in a `ScrollView`, `List`, or `LazyVStack`,
/// allowing callers to choose their own scrolling/container strategy.
///
/// Example:
///
/// ```swift
/// List {
///     PaginatedContent(items: state.items) { item in
///         Row(item)
///     }
///     .onLoadMore { send(.loadMore) }
/// }
/// ```
public struct PaginatedContent<Content: View, Item: Identifiable>: View {
    private let items: [Item]
    private let content: (Item) -> Content
    private let onLoadMore: () -> Void

    @State private var hasRequestedMore = false

    /// Creates a pagination-aware content generator that emits views for each item
    /// and triggers a load-more action when the last item scrolls into view.
    ///
    /// - Parameters:
    ///   - items: The list of items to render. The view emits content in the
    ///     order provided.
    ///   - content: A view-builder closure that produces a view for each item.
    ///   - onLoadMore: A closure called when the final item appears on screen.
    ///     Use this to request the next page of results. This closure will only
    ///     be triggered once per page, and will automatically reset when
    ///     `items.count` changes.
    ///
    /// This view does **not** provide scrolling or layout. You are free to place
    /// it inside any container — such as `ScrollView`, `List`, or `LazyVStack`.
    ///
    /// ```swift
    /// List {
    ///     PaginatedContent(items: state.items) { item in
    ///         Row(item)
    ///     }
    /// }
    /// ```
    public init(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        onLoadMore: @escaping () -> Void = {}
    ) {
        self.items = items
        self.content = content
        self.onLoadMore = onLoadMore
    }

    public var body: some View {
        ForEach(items) { item in
            content(item)
                .onAppear {
                    guard item.id == items.last?.id, !hasRequestedMore else { return }
                    hasRequestedMore = true
                    onLoadMore()
                }
        }
        .onChange(of: items.count) {
            hasRequestedMore = false
        }
    }
}

