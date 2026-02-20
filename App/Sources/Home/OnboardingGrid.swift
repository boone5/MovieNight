//
//  OnboardingGrid.swift
//  App
//
//  Created by Boone on 2/16/26.
//

import ComposableArchitecture
import CoreData
import Models
import SwiftUI

// MARK: - Feature

@Reducer
struct OnboardingGridFeature {
    enum Threshold {
        static let movies = 5
        static let shows = 3
        static let wheelSpins = 3
    }

    @ObservableState
    struct State: Equatable {
        var moviesWithFeedbackCount: Int = 0
        var showsWithFeedbackCount: Int = 0
        var wheelSpinCount: Int = 0

        var allComplete: Bool {
            moviesWithFeedbackCount >= Threshold.movies
                && showsWithFeedbackCount >= Threshold.shows
                && wheelSpinCount >= Threshold.wheelSpins
        }
    }

    enum Action: ViewAction, Equatable {
        case view(View)
    }

    @CasePathable
    enum View: Equatable {
        case moviesWithFeedbackUpdated(newCount: Int)
        case showsWithFeedbackUpdated(newCount: Int)
        case wheelSpinCountUpdated(newCount: Int)
        case rowTapped(RowKind)
    }

    enum RowKind: Equatable {
        case movies
        case tvShows
        case wheel
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(.moviesWithFeedbackUpdated(newCount)):
                state.moviesWithFeedbackCount = newCount
                return .none

            case let .view(.showsWithFeedbackUpdated(newCount)):
                state.showsWithFeedbackCount = newCount
                return .none

            case let .view(.wheelSpinCountUpdated(newCount)):
                state.wheelSpinCount = newCount
                return .none

            case .view(.rowTapped):
                return .none
            }
        }
    }
}

// MARK: - View

@ViewAction(for: OnboardingGridFeature.self)
struct OnboardingGrid: View {
    let store: StoreOf<OnboardingGridFeature>

    @FetchRequest(fetchRequest: Film.moviesWithFeedback())
    private var moviesWithFeedback: FetchedResults<Film>

    @FetchRequest(fetchRequest: Film.showsWithFeedback())
    private var showsWithFeedback: FetchedResults<Film>

    @AppStorage("wheelSpinCount") private var wheelSpinCount: Int = 0

    var body: some View {
        VStack(spacing: 15) {
            Row(
                title: "Start adding movies",
                subtitle: "Leave feedback on movies to unlock suggestions",
                completed: store.moviesWithFeedbackCount,
                total: OnboardingGridFeature.Threshold.movies
            )
            .onTapGesture { send(.rowTapped(.movies)) }

            Divider()

            Row(
                title: "Start watching TV shows",
                subtitle: "Start a new show and we'll keep track",
                completed: store.showsWithFeedbackCount,
                total: OnboardingGridFeature.Threshold.shows
            )
            .onTapGesture { send(.rowTapped(.tvShows)) }

            Divider()

            Row(
                title: "Spin the wheel",
                subtitle: "Use the Watch Wheel to decide what to watch next",
                completed: store.wheelSpinCount,
                total: OnboardingGridFeature.Threshold.wheelSpins
            )
            .onTapGesture { send(.rowTapped(.wheel)) }
        }
        .padding(20)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.secondary, lineWidth: 0.5)
                .foregroundStyle(.secondary)
        )
        .task(id: moviesWithFeedback.count) {
            send(.moviesWithFeedbackUpdated(newCount: moviesWithFeedback.count))
        }
        .task(id: showsWithFeedback.count) {
            send(.showsWithFeedbackUpdated(newCount: showsWithFeedback.count))
        }
        .task(id: wheelSpinCount) {
            send(.wheelSpinCountUpdated(newCount: wheelSpinCount))
        }
    }
}

// MARK: Row

extension OnboardingGrid {
    struct Row: View {
        let title: String
        let subtitle: String
        let completed: Int
        let total: Int

        var body: some View {
            HStack(spacing: 15) {
                ProgressCircle(
                    completed: completed,
                    total: total
                )
                .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .strikethrough(isComplete, color: .secondary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .strikethrough(isComplete, color: .secondary)
                }
                .opacity(isComplete ? 0.5 : 1)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }

        private var isComplete: Bool {
            completed >= total
        }
    }
}

struct ProgressCircle: View {
    let completed: Int
    let total: Int

    @State private var animatedProgress: CGFloat = 0
    @State private var checkmarkScale: CGFloat = 0

    public init(completed: Int, total: Int) {
        self.completed = completed
        self.total = total
    }

    private let animationDelay: CGFloat = 0.3
    private let strokeWidth: CGFloat = 4
    private let progressColor: Color = .goldPopcorn
    private let trackColor: Color = .secondary.opacity(0.3)

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: strokeWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.smooth.delay(animationDelay), value: animatedProgress)
                .onChange(of: completed) { _, _ in
                    animatedProgress = progress()
                }
        }
        .overlay {
            if animatedProgress == 1 {
                Image(systemName: "checkmark")
                    .fontWeight(.black)
                    .foregroundStyle(progressColor)
                    .scaleEffect(checkmarkScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(animationDelay)) {
                            checkmarkScale = 1
                        }
                    }

            } else {
                HStack(spacing: 0) {
                    Text(completed.description)
                        .font(.system(size: 12, weight: .bold))
                        .contentTransition(.numericText())
                    Text(" / ")
                        .font(.system(size: 10, weight: .medium))
                    Text(total.description)
                        .font(.system(size: 10, weight: .medium))
                }
            }
        }
    }

    private func progress() -> CGFloat {
        if completed < total {
            CGFloat(completed) / CGFloat(total)
        } else {
            1
        }
    }
}

#Preview {
    OnboardingGrid(
        store: Store(initialState: OnboardingGridFeature.State()) {
            OnboardingGridFeature()
        }
    )
}
