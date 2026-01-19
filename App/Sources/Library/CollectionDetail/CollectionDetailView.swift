//
//  CollectionDetailView.swift
//  MovieNight
//
//  Created by Boone on 2/18/25.
//

import ComposableArchitecture
import Models
import SwiftUI
import UI
import WatchLater

@ViewAction(for: CollectionDetailFeature.self)
struct CollectionDetailView: View {
    @Bindable var store: StoreOf<CollectionDetailFeature>

    @Namespace private var namespace
    @State private var headerOpacity: CGFloat = 1.0

    var body: some View {
        BackgroundColorView {
            switch store.collection.type {
            case .ranked:
                RankedList(
                    store: store,
                    namespace: namespace,
                    headerOpacity: $headerOpacity
                )
            case .custom, .smart:
                DefaultGridView(
                    store: store,
                    namespace: namespace,
                    headerOpacity: $headerOpacity
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(store.collection.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(1 - headerOpacity)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        // TODO: Search Modal
                        print("open search modal")
                    } label: {
                        Label("Add Films", systemImage: "rectangle.portrait.badge.plus")
                    }

                    Button {
                        send(.startRename)
                    } label: {
                        Label("Rename Collection", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        send(.tappedDeleteCollection)
                    } label: {
                        Label("Delete Collection", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .fullScreenCover(item: $store.selectedFilm) { selectedFilm in
            FilmDetailView(
                film: selectedFilm.film,
                navigationTransitionConfig: .init(namespace: namespace, source: selectedFilm.film)
            )
        }
    }
}

@ViewAction(for: CollectionDetailFeature.self)
struct DefaultGridView: View {
    @Bindable var store: StoreOf<CollectionDetailFeature>
    let namespace: Namespace.ID
    @Binding var headerOpacity: CGFloat

    private let gridItems: [GridItem] = [
        GridItem(.flexible(), spacing: 15, alignment: .center),
        GridItem(.flexible(), spacing: 15, alignment: .center)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                CollectionDetailViewHeader(
                    title: $store.collection.title,
                    type: store.collection.type,
                    filmCount: store.collection.filmCount,
                    headerOpacity: $headerOpacity,
                    isEditingTitle: $store.isEditingTitle,
                    onConfirmRename: {
                        send(.confirmRename)
                    },
                    onCancelRename: {
                        send(.cancelRename)
                    }
                )
                .padding(.top, 10)

                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(Array(store.films.enumerated()), id: \.element.id) { index, film in
                        VStack(spacing: 10) {
                            ThumbnailView(
                                filmID: film.id,
                                posterPath: film.posterPath,
                                size: CGSize(width: 175, height: 225),
                                transitionConfig: .init(namespace: namespace, source: film)
                            )
                            .onTapGesture {
                                send(.rowTapped(film))
                            }

                            HStack {
                                Text(film.title ?? "")
                                    .font(.system(size: 12))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Menu {
                                    Button(role: .destructive) {
                                        // TODO: Delete Film from collection
                                        print("delete movie from collection")
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                }
            }
            .padding(.horizontal, PLayout.horizontalMarginPadding)
        }
    }
}

struct CollectionDetailViewHeader: View {
    @Binding public var title: String
    public let type: CollectionType
    public let filmCount: Int
    @Binding public var headerOpacity: CGFloat
    @Binding public var isEditingTitle: Bool
    public var onConfirmRename: (() -> Void)? = nil
    public var onCancelRename: (() -> Void)? = nil

    @State private var initialMinY: CGFloat?
    @FocusState private var isTitleFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 12) {
                if isEditingTitle {
                    TextField("Collection Name", text: $title)
                        .font(.montserrat(size: 34, weight: .bold))
                        .textFieldStyle(.plain)
                        .focused($isTitleFieldFocused)
                        .onAppear {
                            isTitleFieldFocused = true
                        }

                    Button {
                        onConfirmRename?()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.green)
                    }

                    Button {
                        onCancelRename?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.red)
                    }
                } else {
                    Text(title)
                        .font(.montserrat(size: 34, weight: .bold))
                }
            }

            HStack(spacing: 8) {
                Group {
                    Text("\(type.title)")
                    Text("•")
                    Text("\(filmCount) films")
                }
                .font(.openSans(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(headerOpacity)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.frame(in: .scrollView).minY
        } action: { minY in
            if initialMinY == nil {
                initialMinY = minY
            }
            let normalizedMinY = minY - (initialMinY ?? 0)
            let fadeThreshold = 80.0
            headerOpacity = max(0, min(1, (fadeThreshold + normalizedMinY) / fadeThreshold))
        }
        .onChange(of: isEditingTitle) { _, newValue in
            isTitleFieldFocused = newValue
        }
    }
}

extension CollectionType {
    enum Action {
        case addFilm
        case reorder
        case rename

        var title: String {
            switch self {
            case .addFilm: "Add"
            case .reorder: "Reorder"
            case .rename:  "Rename"
            }
        }

        var icon: String {
            switch self {
            case .addFilm: "plus"
            case .reorder: "arrow.trianglehead.swap"
            case .rename:  "pencil"
            }
        }
    }

    var actions: [Action] {
        switch self {
        case .custom:
            [.addFilm, .rename]
        case .ranked:
            [.addFilm, .rename, .reorder]
        case .smart:
            [.addFilm, .rename]
        }
    }
}

@ViewAction(for: CollectionDetailFeature.self)
struct RankedList: View {
    @Bindable var store: StoreOf<CollectionDetailFeature>
    let namespace: Namespace.ID
    @Binding var headerOpacity: CGFloat

    var body: some View {
        List {
            CollectionDetailViewHeader(
                title: $store.collection.title,
                type: store.collection.type,
                filmCount: store.collection.filmCount,
                headerOpacity: $headerOpacity,
                isEditingTitle: $store.isEditingTitle,
                onConfirmRename: {
                    send(.confirmRename)
                },
                onCancelRename: {
                    send(.cancelRename)
                }
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            ForEach(Array(store.films.enumerated()), id: \.element.id) { idx, film in
                Row(
                    rank: idx + 1,
                    film: film,
                    namespace: namespace
                )
                .onTapGesture {
                    send(.rowTapped(film))
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.visible, edges: .bottom)
                .listRowSeparator(.hidden, edges: .top)
            }
            .onMove { store.films.move(fromOffsets: $0, toOffset: $1) }
            .onDelete(perform: { store.films.remove(atOffsets: $0) })
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(store.isEditing ? .active : .inactive))
    }

    struct Row: View {
        let rank: Int
        let film: Film
        let namespace: Namespace.ID

        var body: some View {
            HStack(spacing: 15) {
                Text("\(rank)")
                    .font(.openSans(size: 18, weight: .bold))
                    .foregroundStyle(.secondary)

                ThumbnailView(
                    filmID: film.id,
                    posterPath: film.posterPath,
                    size: CGSize(width: 60, height: 90),
                    transitionConfig: .init(namespace: namespace, source: film)
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(film.title ?? "-")
                        .font(.openSans(size: 16, weight: .medium))
                        .lineLimit(2)

                    if let releaseDate = film.releaseDate {
                        Text(releaseDate.prefix(4))
                            .font(.openSans(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    @Previewable @Dependency(\.movieProvider) var movieProvider
    let context = movieProvider.container.viewContext

    let collection = CollectionModel(
        id: UUID(),
        title: "Top 10 Films",
        type: .custom,
        dateCreated: Date(),
        filmCount: 10
    )

    var films = [Film]()
    let titles = ["The Shawshank Redemption", "The Godfather", "The Dark Knight", "Pulp Fiction", "Fight Club", "Inception", "The Matrix", "Goodfellas", "Se7en", "The Silence of the Lambs"]
    for i in 0..<10 {
        let film = Film(context: context)
        film.id = Int64(i)
        film.title = titles[i]
        film.posterPath = "/jNsttCWZyPtW66MjhUozBzVsRb7.jpg"
        film.releaseDate = "199\(i)-01-01"
        films.append(film)
    }

    return NavigationStack {
        CollectionDetailView(
            store: Store(
                initialState: CollectionDetailFeature.State(
                    collection: collection,
                    films: films
                )
            ) {
                CollectionDetailFeature()
            }
        )
    }
}
