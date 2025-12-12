//
//  WheelView.swift
//  MovieNight
//
//  Created by Boone on 7/12/25.
//

import Dependencies
import Models
import Networking
import SwiftUI
import UI

import FortuneWheel

struct WheelView: View {
    @State private var radius: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var winningName: String = ""
    @State private var names: [String] = [""]

    @State private var winningRotation: Double = 0

    private let totalSpinDuration: Double = 5.0
    private let totalRotations: Double = 3500

    private let films: [Film]
    private let segmentCount: Int

    init(films: [Film]) {
        self.films = films

        if films.isEmpty {
            segmentCount = 1
        } else {
            segmentCount = films.count
        }
    }

    private var wheelModel: FortuneWheelModel {
        FortuneWheelModel(
            titles: films.compactMap(\.title),
            size: 350,
            colors: nil,
            sliceConfig: .init(strokeWidth: 10),
            pointerConfig: .init(pointerColor: .green),
            middleBoltConfig: .init(outerSize: 25, innerSize: 16),
            animationConfig: .init(duration: totalSpinDuration),
            onSpinStateChange: {
                switch $0 {
                case .idle:
                    print("IDLE")
                case .spinning:
                    print("Spinning...")
                case .finished(let index):
                    print("Finished!")
                    winningName = films[safe: index]?.title ?? ""
                }
            }
        )
    }

    var body: some View {
        BackgroundColorView {
            VStack(spacing: 0) {
                Spacer()
                Text("Spin the wheel!")
                    .font(.system(size: 30, weight: .bold))

                Text("What will you watch next?")
                    .font(.system(size: 16, weight: .medium))
                    .padding(.top, 5)

                Spacer()


                FortuneWheel(
                    model: wheelModel
                )



                Spacer()
                Button(action: {}) {
                    Text(isSpinning ? "Spinning..." : "Spin")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                }
                .padding()
                .frame(width: 200)
                .glassEffect(.regular.interactive(!isSpinning), in: .rect(cornerRadius: 10))
                .disabled(isSpinning)
                Spacer()

            }
            .alert(winningName, isPresented: .constant(!winningName.isEmpty)) {
                Button("Spin Again") {
                    self.winningName = ""
                    self.rotation = 0
                    self.isSpinning = false
                }

                Button("Close") {
                    self.winningName = ""
                }
            } message: {

            }
        }
    }
}

extension Collection {
    /// Returns the element at `index` if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

import CoreData

#Preview {
    struct WheelViewPreview: View {
        let films: [Film] = {
            @Dependency(\.movieProvider) var movieProvider
            let context = movieProvider.container.viewContext
            let watchList = FilmCollection(context: context)
            watchList.id = FilmCollection.watchLaterID

            var films: [Film] = []

            for i in 0..<3 {
                let film = Film(context: context)
                film.title = "Mock Film \(i)"
                films.append(film)
            }
            return films
        }()

        var body: some View {
            WheelView(films: films)
        }
    }

    return NavigationStack { WheelViewPreview() }
}

struct WheelSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
