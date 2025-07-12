//
//  WheelView.swift
//  MovieNight
//
//  Created by Boone on 7/12/25.
//

import SwiftUI

struct WheelView: View {
    @State private var radius: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var winningName: String = ""
    @State private var names: [String] = [""]
    @State private var winningColor: [String] = []

    private let colors: [Color] = [.red, .yellow]
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
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(zip(films.indices, films)), id: \.0) { idx, film in
                    let startAngle = self.angleForSegment(idx)
                    let endAngle = self.angleForSegment(idx + 1)
                    let mean: Angle = (startAngle + endAngle) / 2
                    // Calculate the chord's angle using arctan2.
                    let chordAngleRadians = atan2(
                        sin(endAngle.radians) - sin(startAngle.radians),
                        cos(endAngle.radians) - cos(startAngle.radians)
                    )
                    let chordAngle = Angle(radians: chordAngleRadians)

                    ZStack {
                        Segment(startAngle: startAngle, endAngle: endAngle)
                            .fill(colors[idx % colors.count])
                            .onAppear {
                                let midX = geometry.frame(in: .local).midX
                                radius = midX
                            }

                        Text(film.title ?? "N/A")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: 100)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .rotationEffect(chordAngle + Angle(degrees: 90))
                            .offset(
                                CGSize(
                                    width: radius * 0.5 * cos(mean.radians),
                                    height: radius * 0.5 * sin(mean.radians)
                                )
                            )
                    }
                    .rotationEffect(.degrees(rotation))
                }

                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)

                Arrow()
                    .fill(Color.gray)
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(180))
                    .offset(x: 150, y: 0)
                    .shadow(color: .gray, radius: 4, x: 2, y: 2)
            }
            .onTapGesture {
                spinRoulette()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    func angleForSegment(_ index: Int) -> Angle {
        Angle(degrees: Double(index) / Double(segmentCount) * 360)
    }

    func textAngleForSegment(_ index: Int) -> Angle {
        let segmentAngle = 360.0 / Double(segmentCount)
        return Angle(degrees: -Double(index) * segmentAngle - segmentAngle / 2)
    }

    func spinRoulette() {
        guard !isSpinning else { return }
        isSpinning = true

        withAnimation(Animation.timingCurve(0.1, 0.8, 0.3, 1.0, duration: totalSpinDuration)) {
            rotation += totalRotations
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalSpinDuration) {
            isSpinning = false
        }
    }
}

struct Segment: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
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
