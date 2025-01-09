//
//  MockLibraryScreen.swift
//  MovieNight
//
//  Created by Boone on 6/30/24.
//

import SwiftUI

struct LibraryScreen: View {
    @StateObject private var thumbnailViewModel = ThumbnailView.ViewModel()

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "dateWatched", ascending: false)])
    var movies: FetchedResults<Movie>

    @State var isExpanded: Bool = false
    @State var selectedFilm: SelectedFilm?
    @Namespace private var namespace

    let layout = [
        GridItem(.adaptive(minimum: 120)),
        GridItem(.adaptive(minimum: 120)),
    ]

    enum MovieCollection: Identifiable, CaseIterable {
        var id: String { UUID().uuidString }

        case movies
        case tvShows
        case watchLater

        var title: String {
            switch self {
            case .movies:
                return "Movies"
            case .tvShows:
                return "TV Shows"
            case .watchLater:
                return "Watch Later"
            }
        }

        var count: Int {
            switch self {
            case .movies:
                return 10
            case .tvShows:
                return 20
            case .watchLater:
                return 5
            }
        }
    }

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    LinearGradient(
                        colors: [Color("BackgroundColor1"), Color("BackgroundColor2")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .center, spacing: 0) {
                    HStack(spacing: 10) {
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)

                        Text("hunter")
                            .foregroundStyle(.white)
                            .font(.system(size: 18, weight: .regular))
                    }
                    .padding(.top, 15)
                }
                .padding(15)
                .background {
                    Color("BackgroundColor1").ignoresSafeArea()
                        .shadow(color: .black, radius: 10, y: -2)
                }

                if movies.isEmpty {
                    Spacer()
                    Text("Start watching films to build your library.")
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 15)
                    Spacer()

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Recently Watched")
                                .foregroundStyle(.white)
                                .font(.system(size: 22, weight: .semibold))
                                .padding([.leading, .bottom], 15)
                                .padding(.top, 15)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(movies, id: \.id) { movie in
                                        if selectedFilm?.id == movie.id, isExpanded {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.clear)
                                                .frame(width: 175, height: 250)
                                        } else {
                                            ThumbnailView(
                                                viewModel: thumbnailViewModel,
                                                filmID: movie.id,
                                                posterPath: movie.posterPath,
                                                width: 175,
                                                height: 250,
                                                namespace: namespace
                                            )
                                                .onTapGesture {
                                                    withAnimation(.spring()) {
                                                        isExpanded = true
                                                        selectedFilm = SelectedFilm(id: movie.id, film: movie, posterImage: thumbnailViewModel.posterImage(for: movie.posterPath))
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding(.leading, 15)
                            }

                            Text("Collections")
                                .foregroundStyle(.white)
                                .font(.system(size: 22, weight: .semibold))
                                .padding(.top, 30)
                                .padding(.bottom, 20)
                                .padding([.leading, .trailing], 15)

                            // TODO: Causing issues when opening film detail view
//                            LazyVGrid(columns: layout) {
//                                // Movies, TV Shows, Watch Later
//                                ForEach(MovieCollection.allCases) { type in
//                                    HStack {
//                                        ZStack {
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .frame(width: 40, height: 60)
//                                                .foregroundStyle(.red)
//                                                .scaleEffect(0.8)
//                                                .offset(x: 15)
//
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .frame(width: 40, height: 60)youtube 
//                                                .foregroundStyle(.blue)
//                                                .scaleEffect(0.9)
//                                                .offset(x: 8)
//
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .frame(width: 40, height: 60)
//                                                .foregroundStyle(.green)
//                                        }
//
//                                        VStack(alignment: .leading, spacing: 5) {
//                                            Text(type.title)
//                                                .foregroundStyle(Color(uiColor: MovieNightColors.subtitle))
//                                                .font(.system(size: 12, weight: .medium))
//
//                                            // MARK: TODO - Add red background for Watch Later
//                                            Text(String(type.count))
//                                                .foregroundStyle(Color(uiColor: MovieNightColors.body))
//                                                .font(.system(size: 10, weight: .regular))
//                                        }
//                                        .padding(.leading, 20)
//
//                                        Spacer()
//                                    }
//                                    .padding(15)
//                                    .background {
//                                        RoundedRectangle(cornerRadius: 25)
//                                            .foregroundStyle(Color(.brightRed).opacity(0.4))
//                                    }
//                                }
//                            }
//                            .padding([.leading, .trailing], 15)

                        }
                    }
                }
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
            .toolbar(isExpanded ? .hidden : .visible, for: .tabBar)
        }
    }
}

//#Preview {
//    MockLibraryScreen()
//}

extension LibraryScreen {
    class ViewModel: ObservableObject {
        
    }
}
