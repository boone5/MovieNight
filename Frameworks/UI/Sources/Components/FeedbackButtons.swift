//
//  ActionView3.swift
//  MovieNight
//
//  Created by Boone on 1/2/25.
//

import Models
import SwiftUI

struct FeedbackButtons: View {
    @Binding public var feedback: Feedback?
    public let averageColor: Color

    var onButtonTap: ((Feedback) -> Void)?

    var body: some View {
        HStack(spacing: 20) {
            ForEach(Feedback.allCases, id: \.self) { type in
                ButtonView(type: type, selectedType: $feedback, averageColor: averageColor) {
                    onButtonTap?($0)
                }
            }
        }
    }

    fileprivate struct ButtonView: View {
        let type: Feedback
        @Binding var selectedType: Feedback?
        let averageColor: Color

        var onButtonTap: ((Feedback) -> Void)?

        var body: some View {
            Button {
                selectedType = type
                onButtonTap?(type)
            } label: {
                Image(systemName: type.imageName)
                    .symbolVariant(selectedType == type ? .fill : .none)
                    .contentTransition(.symbolEffect(.automatic))
                    .foregroundStyle(type.color)
                    .font(.system(size: 24, weight: .medium))
                    .padding(20)
                    .background {
                        Group {
                            if type == selectedType {
                                Color(type.color).opacity(0.2)
                            } else {
                                averageColor.opacity(0.4)
                            }
                        }
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
                    }
            }
        }
    }
}

#Preview {
    @Previewable @State var feedback: Feedback? = nil

    VStack {
        FeedbackButtons(feedback: $feedback, averageColor: .deepRed) { newFeedback in
            withAnimation {
                feedback = newFeedback
            }
        }

        Button("Clear Feedback") {
            feedback = nil
        }
    }
}
