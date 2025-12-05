//
//  Search.swift
//  MovieNight
//
//  Created by Boone on 8/12/23.
//

import Networking
import SwiftUI

enum SearchState {
    case explore
    case results
}

struct SelectedFilm {
    var id: Int64
    var film: DetailViewRepresentable
    var posterImage: UIImage?
}

// filter by provider (apple tv, prime, hulu, etc)

struct SearchScreen: View {
    @StateObject private var viewModel = SearchViewModel()

    // Expanded View Properties
    @State private var isExpanded: Bool = false
    @State private var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    @State private var searchText: String = ""
    @State private var headerOpacity: Double = 1.0

    var body: some View {
        BackgroundColorView {
            if searchText.isEmpty {
                VStack(spacing: 10) {
                    Text("What's Pop'n?")
                        .font(.title3.bold())

                    Text("Find your next movie, tv show, friend, or favorite cast member.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 15)

            } else {
                // Loading View
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 30)
                } else {
                    // Results
                    ListView(
                        viewModel: viewModel,
                        results: viewModel.results,
                        namespace: namespace,
                        isExpanded: $isExpanded,
                        selectedFilm: $selectedFilm
                    )
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .searchable(text: $searchText)
        .scrollDismissesKeyboard(.immediately)
        .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
        .onChange(of: searchText) { _, newValue in
            viewModel.search(query: newValue)
        }
        .opacity(isExpanded ? 0 : 1)
        .overlay {
            if let selectedFilm, isExpanded {
                FilmDetailView(
                    film: selectedFilm.film,
                    namespace: namespace,
                    isExpanded: $isExpanded,
                    uiImage: selectedFilm.posterImage
                )
                .transition(.asymmetric(insertion: .identity, removal: .opacity))
            }
        }
    }
}

struct ListView: View {
    @StateObject private var thumbnailViewModel = ThumbnailView.ViewModel()

    @ObservedObject var viewModel: SearchViewModel
    let results: [DetailViewRepresentable]
    let namespace: Namespace.ID

    @Binding var isExpanded: Bool
    @Binding var selectedFilm: SelectedFilm?

    var body: some View {
        List {
            if !results.isEmpty {
                Group {
                    ForEach(results, id: \.id) { film in
                        HStack(spacing: 0) {
                            if selectedFilm?.id == film.id, isExpanded {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.gray)
                                    .frame(width: 80, height: 120)
                                    .shadow(radius: 3, y: 4)

                            } else {
                                ThumbnailView(
                                    viewModel: thumbnailViewModel,
                                    filmID: film.id,
                                    posterPath: film.posterPath,
                                    width: 80,
                                    height: 120,
                                    namespace: namespace
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        isExpanded = true
                                        selectedFilm = SelectedFilm(id: film.id, film: film, posterImage: thumbnailViewModel.posterImage(for: film.posterPath))
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(film.title ?? "")
                                    .font(.system(size: 16, weight: .medium))

                                Text(film.mediaType.title)
                                    .font(.system(size: 14, weight: .regular))
                            }
                            .padding(.leading, 20)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }

                    // Make this a "couldn't find what you were looking for?" button to submit feedback
                    Text("End of List")
                        .foregroundStyle(.white)
                        .listRowBackground(Color.clear)
                        .onAppear {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                }
                .listRowBackground(Color.clear)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SearchScreen()
}
