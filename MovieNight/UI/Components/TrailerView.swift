//
//  TrailerView.swift
//  MovieNight
//
//  Created by Boone on 3/7/25.
//

import SwiftUI
import YouTubePlayerKit
import Combine

struct TrailerView: View {
    @StateObject private var youtubePlayer: YouTubePlayer

    @State private var subscription: AnyCancellable? // Store the subscription

    init(videoID: String) {
        self._youtubePlayer = StateObject(wrappedValue: YouTubePlayer(
            source: .video(id: videoID),
            parameters: .init(
                autoPlay: false,
                showControls: true,
                showFullscreenButton: true
            ),
            configuration: .init(
                fullscreenMode: .system,
                allowsInlineMediaPlayback: false,
                allowsAirPlayForMediaPlayback: true
            ),
            isLoggingEnabled: false
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            YouTubePlayerView(youtubePlayer) { state in
                switch state {
                case .idle:
                    ProgressView()

                case .error(let error):
                    Text("Error showing media player: \(error)")

                case .ready:
                    EmptyView()
                }
            }
            .aspectRatio(CGSize(width: 1280, height: 720), contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        //        .onAppear {
        //            // Store the subscription to retain it
        //            subscription = youtubePlayer.eventPublisher.sink { event in
        //                switch event.name {
        //                case .fullscreenChange:
        //                    if let data = event.data?.value.data(using: .utf8) {
        //                        do {
        //                            let event = try JSONDecoder().decode(YouTubeEventData.self, from: data)
        //                            if event.fullscreen ?? false {
        //                                // The player is entering fullscreen mode
        //                                break
        //                            } else {
        //                                // The player is leaving fullscreen mode
        //                                isFullscreen = false
        //                            }
        //                        } catch {
        //                            print("Failed to decode event data: \(error)")
        //                        }
        //                    }
        //
        //                    break
        //                default:
        //                    break
        //                }
        //            }
        //        }
    }
}

struct YouTubeEventData: Codable {
    let fullscreen: Bool?
    let videoId: String?
    let time: TimeInterval?
}
