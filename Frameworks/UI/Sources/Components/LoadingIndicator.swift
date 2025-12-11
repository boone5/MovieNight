//
//  LoadingIndicator.swift
//  Frameworks
//
//  Created by Ayren King on 12/7/25.
//

import Combine
import SwiftUI

public struct LoadingIndicator: View {
    let timing: Double
    let maxCounter: Int = 5

    @State var counter = 0

    let frame: CGSize
    let primaryColor: Color

    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: timing, on: .main, in: .common).autoconnect()
    }

    public init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.5) {
        timing = speed / 2
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    public var body: some View {
        HStack(spacing: frame.width / 10) {
            ForEach(0..<maxCounter, id: \.self) { index in
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(primaryColor)
                    .frame(maxHeight: counter == index ? frame.height / 3 : .infinity)
            }
        }
        .frame(width: frame.width, height: frame.height)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: timing)) {
                counter = counter == maxCounter - 1 ? 0 : counter + 1
            }
        }
    }
}
