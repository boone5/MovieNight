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

struct WheelView: View {
    @State private var radius: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var winningName: String = ""
    @State private var names: [String] = [""]

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

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("Spin the wheel!")
                .font(.system(size: 30, weight: .bold))

            Text("What will you watch next?")
                .font(.system(size: 16, weight: .medium))
                .padding(.top, 5)

            Spacer()

            ZStack {
                        ForEach(0..<segmentCount, id: \.self) { index in
                            let startAngle = Angle(degrees: Double(index) / Double(segmentCount) * 360)
                            let endAngle = Angle(degrees: Double(index + 1) / Double(segmentCount) * 360)
                            let textAngle = (startAngle + endAngle) / 2
                            let textXOffset = 100 * cos(CGFloat(textAngle.radians - .pi / 2))
                            let textYOffset = 100 * sin(CGFloat(textAngle.radians - .pi / 2))


                            // wheel segment with film title
                            WheelSegment(startAngle: startAngle, endAngle: endAngle)
                                .stroke(.black)
                                .overlay(
                                    Text(films[safe: index]?.title ?? "No Films")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                        .rotationEffect(.degrees((Double(index) + 0.5) / Double(segmentCount) * 360))
                                        .offset(
                                            x: textXOffset,
                                            y: textYOffset
                                            
                                        )
//                                        .rotationEffect(-.degrees(rotation))
                                )
                        }

                        // Example 2: Optional, a central circle overlay
                        Circle()
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 50, height: 50)
                            .background(.white)
                            .clipShape(Circle())
                    }
                    .frame(width: 350, height: 350)
                    .rotationEffect(.degrees(rotation))
                    .overlay(alignment: .top) {
                        Arrow()
                            .fill(Color.gray)
                            .frame(width: 30, height: 30)
                            .rotationEffect(Angle(degrees: 90))
                            .offset(y: -10)
                    }



            Spacer()
            Button(action: spinRoulette) {
                Text(isSpinning ? "Spinning..." : "Spin")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(isSpinning ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isSpinning)
            Spacer()

        }
        .alert(winningName, isPresented: .constant(!winningName.isEmpty)) {
            Button("Spin Again") {
                self.winningName = ""
                self.rotation = 0
                self.isSpinning = false
                spinRoulette()
            }

            Button("Close") {
                self.winningName = ""
            }
        } message: {

        }

    }

    func spinRoulette() {
        guard !isSpinning else { return }
        isSpinning = true

        // Randomize the final rotation angle to land on a random segment
        let randomOffset = Double.random(in: 0..<(360.0))
        let finalRotation = totalRotations + randomOffset
        withAnimation(Animation.timingCurve(0.1, 0.8, 0.3, 1.0, duration: totalSpinDuration)) {
            rotation += finalRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalSpinDuration) {
            isSpinning = false
            // which segment contains the 90 degree mark
            let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
            let degreesPerSegment = 360.0 / Double(segmentCount)
            let winningIndex = Int(((360 - normalizedRotation + (degreesPerSegment / 2)) .truncatingRemainder(dividingBy: 360)) / degreesPerSegment)
            winningName = films[safe: winningIndex]?.title ?? "No Films"
        }
    }
}

struct Segment: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)

        path.addArc(
            center: center,
            radius: rect.width / 2,
            startAngle: startAngle - Angle(degrees: 90),
            endAngle: endAngle - Angle(degrees: 90),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        path.move(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
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

    return WheelViewPreview()
}

struct WheelSegment: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadius: CGFloat = 0 // Allows for a hollow center (a ring segment)

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2

        var path = Path()

        // Move to the inner start point if it's a ring segment, otherwise the center
        if innerRadius > 0 {
            let innerStartPoint = CGPoint(
                x: center.x + innerRadius * cos(CGFloat(startAngle.radians)),
                y: center.y + innerRadius * sin(startAngle.radians)
            )
            path.move(to: innerStartPoint)

            // Draw the inner arc
            path.addArc(
                center: center,
                radius: innerRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        } else {
            path.move(to: center)
        }

        // Draw the outer arc
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false // or true, depending on desired direction
        )

        // Close the path back to the center (if full wedge) or inner radius start
        path.closeSubpath()

        return path
    }
}
