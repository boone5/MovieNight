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

    init(store: StoreOf<CollectionDetailFeature>) {
        self.store = store

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        // Customize title color & font if needed
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]

        // Apply appearance to navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        BackgroundColorView {
            VStack {
                switch store.collection.type {
                case .ranked:
                    RankedList(
                        collection: store.collection,
                        films: $store.films,
                        namespace: namespace,
                        headerOpacity: $headerOpacity,
                        isEditing: store.isEditing,
                        onTap: { film in
                            send(.rowTapped(film))
                        },
                        onActionTap: { action in
                            send(.actionTapped(action))
                        }
                    )
                case .custom, .smart:
                    ScrollView {
                        VStack {
                            CollectionDetailViewHeader(
                                collection: store.collection,
                                headerOpacity: $headerOpacity,
                                didTapAction: { action in
                                    send(.actionTapped(action))
                                }
                            )

                            WatchList(
                                watchList: store.films,
                                namespace: namespace,
                                selectedFilm: $store.selectedFilm
                            )
                            .padding(.top, 15)
                        }
                        .padding(.horizontal, PLayout.horizontalMarginPadding)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(store.collection.safeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(1 - headerOpacity)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
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

struct CollectionDetailViewHeader: View {
    public let collection: FilmCollection
    @Binding public var headerOpacity: CGFloat
    public var didTapAction: ((CollectionType.Action) -> Void)? = nil

    @State private var initialMinY: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(collection.safeTitle)
                .font(.montserrat(size: 34, weight: .bold))

            HStack(spacing: 8) {
                Text("\(collection.type.title) Collection")
                    .font(.openSans(size: 16))
                    .foregroundStyle(.secondary)

                Text("•")
                    .font(.openSans(size: 16))
                    .foregroundStyle(.secondary)

                Text("\(collection.films?.count ?? 0) films")
                    .font(.openSans(size: 16))
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(collection.type.actions, id: \.self) { action in
                        Button {
                            didTapAction?(action)
                        } label: {
                            HStack {
                                Image(systemName: action.icon)
                                    .font(.system(size: 14))

                                Text(action.title)
                                    .font(.openSans(size: 14))
                                    .foregroundStyle(.black)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background {
                                Capsule()
                                    .foregroundStyle(Color.goldPopcorn)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, PLayout.horizontalMarginPadding)
            }
            .padding(.horizontal, -PLayout.horizontalMarginPadding)
            .padding(.top, 5)
        }
        .opacity(headerOpacity)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.frame(in: .scrollView).minY
        } action: { minY in
            if initialMinY == nil {
                initialMinY = minY
            }
            let normalizedMinY = minY - (initialMinY ?? 0)
            let fadeThreshold = 125.0
//            print("Raw minY: \(minY), Initial: \(initialMinY ?? 0), Normalized: \(normalizedMinY)")
            // When scrolling up, normalizedMinY goes negative
            // opacity should fade from 1 to 0 as we scroll from 0 to -50
            headerOpacity = max(0, min(1, (fadeThreshold + normalizedMinY) / fadeThreshold))
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

struct RankedList: View {
    let collection: FilmCollection
    @Binding var films: [Film]
    let namespace: Namespace.ID
    @Binding var headerOpacity: CGFloat
    var isEditing: Bool = false
    var onTap: ((Film) -> Void)? = nil
    var onActionTap: ((CollectionType.Action) -> Void)? = nil

    var body: some View {
        List {
            CollectionDetailViewHeader(
                collection: collection,
                headerOpacity: $headerOpacity,
                didTapAction: onActionTap
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            ForEach(Array(films.enumerated()), id: \.element.id) { idx, film in
                Row(
                    rank: idx + 1,
                    film: film,
                    namespace: namespace
                )
                .onTapGesture {
                    onTap?(film)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.visible, edges: .bottom)
                .listRowSeparator(.hidden, edges: .top)
            }
            .onMove { films.move(fromOffsets: $0, toOffset: $1) }
            .onDelete(perform: { films.remove(atOffsets: $0) } )
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
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
    let collection = FilmCollection(context: context)
    collection.id = UUID()
    collection.title = "Top 10 Films"
    collection.dateCreated = Date()
    collection.type = .custom

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
