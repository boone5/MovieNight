//
//  FlippablePosterView.swift
//  MovieNight
//
//  Created by Boone on 8/2/25.
//

import Models
import SwiftUI

struct FlippablePosterView: View {
    @State private var flipDegrees: Double = 0
    @State private var shimmyRotation: Double = 0

    private let posterWidth: CGFloat
    private let posterHeight: CGFloat
    private let averageColor: Color
    private let namespace: Namespace.ID
    private let film: FilmDisplay
    @Binding var trailer: AdditionalDetailsMovie.VideoResponse.Video?

    init(
        film: FilmDisplay,
        averageColor: Color,
        namespace: Namespace.ID,
        trailer: Binding<AdditionalDetailsMovie.VideoResponse.Video?>
    ) {
        self.film = film
        self.averageColor = averageColor
        self.namespace = namespace
        self._trailer = trailer

        let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size ?? .zero

        self.posterWidth = size.width / 1.5
        self.posterHeight = size.height / 2.4
    }

    // Normalize the degrees into [0, 360) for determining which side is visible.
    var normalizedDegrees: Double {
        abs(flipDegrees.truncatingRemainder(dividingBy: 360))
    }

    var frontVisible: Bool {
        normalizedDegrees < 90 || normalizedDegrees > 270
    }

    var body: some View {
        ZStack {
            // Front
            PosterView(
                imagePath: film.posterPath,
                width: posterWidth,
                height: posterHeight,
                filmID: film.id,
                namespace: namespace
            )
            .shadow(radius: 6, y: 3)
            .overlay(alignment: .bottomTrailing) {
                Text("Info")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .background {
                        averageColor.opacity(0.5)
                            .clipShape(Capsule())
                    }
                    .padding([.bottom, .trailing], 15)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 1.2)) {
                            flipDegrees -= 180
                        }
                    }
            }
            .opacity(frontVisible ? 1 : 0)
            .rotation3DEffect(
                .degrees(flipDegrees),
                axis: (x: 0, y: 1, z: 0)
            )

            PosterBackView(
                film: film,
                backgroundColor: averageColor,
                trailer: $trailer
            )
            .frame(width: posterWidth, height: posterHeight)
            .cornerRadius(8)
            .shadow(radius: 6, y: 3)
            .opacity(frontVisible ? 0 : 1)
            // Add 180° so that when the card flips, the back isn’t upside down.
            .rotation3DEffect(
                .degrees(flipDegrees + 180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        // Apply the shimmy rotation effect.
        .rotation3DEffect(.degrees(shimmyRotation), axis: (x: 0, y: 1, z: 0))
        .onAppear {
            let shimmyAnimation = Animation
                .bouncy(duration: 1.2, extraBounce: 0.4)
                .repeatCount(2)

            withAnimation(shimmyAnimation) {
                shimmyRotation = 7

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(shimmyAnimation) {
                        shimmyRotation = 0
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    withAnimation(.bouncy(duration: 1.2)) {
                        // For a left-to-right swipe, add 180°.
                        if value.translation.width > 0 {
                            flipDegrees += 180
                        } else if value.translation.width < 0 {
                            // For a right-to-left swipe, subtract 180°.
                            flipDegrees -= 180
                        }
                    }
                }
        )
    }
}

//#Preview {
//    @Previewable @State var isExpanded: Bool = true
//    @Previewable @Namespace var namespace
//
//    let previewCD = MovieProvider.preview.container.viewContext
//    let film: ResponseType = ResponseType.movie(MovieResponse())
////    let film: ResponseType = ResponseType.tvShow(TVShowResponse())
//
//    FlippablePosterView(
//        film: film,
//        averageColor: .red,
//        namespace: namespace,
//        uiImage: nil,
//        trailer: nil
//    )
//}
