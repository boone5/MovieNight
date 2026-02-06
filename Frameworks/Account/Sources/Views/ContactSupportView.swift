import SwiftUI
import UI

public struct ContactSupportView: View {
    @Environment(\.openURL) private var openURL
    private let supportEmail = "support@example.com" // TODO: replace with real support email

    public init() {}

    public var body: some View {
        BackgroundColorView {
            List {
                Group {
                    Section("Contact Info") {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundStyle(.secondary)
                            Text(supportEmail)
                                .font(.openSans(size: 16))
                            Spacer()
                            Button("Copy") {
                                UIPasteboard.general.string = supportEmail
                            }
                            .buttonStyle(.bordered)
                            .tint(.primary)
                        }
                        .listRow(isFirst: true)

                        Button {
                            if let url = URL(string: "mailto:\(supportEmail)") {
                                openURL(url)
                            }
                        } label: {
                            Label("Email Us", systemImage: "paperplane")
                                .font(.openSans(size: 16))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                        .listRow(isLast: true)
                    }
                    .font(.openSans(size: 16, weight: .semibold))

                    Section("") {
                        NavigationLink {
                            FeedbackFormView()
                        } label: {
                            Label("Write Feedback", systemImage: "square.and.pencil")
                                .font(.openSans(size: 16))
                                .foregroundStyle(.primary)
                        }
                        .listRow(isFirst: true, isLast: true)
                    }
                }
                .listRowBackground(Color.background)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: PLayout.horizontalMarginPadding, bottom: 0, trailing: PLayout.horizontalMarginPadding))
            }
            .foregroundStyle(.primary)
            .listStyle(.plain)
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum FeedbackRating: String, CaseIterable, Identifiable {
    case great = "Great"
    case okay = "Okay"
    case bad = "Bad"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .great: "hand.thumbsup"
        case .okay: "face.smiling"
        case .bad: "hand.thumbsdown"
        }
    }

    var color: Color {
        switch self {
        case .great: .goldPopcorn
        case .okay: .gray
        case .bad: .popRed
        }
    }
}

private enum FeedbackCategory: String, CaseIterable, Identifiable {
    case ui = "UI & Design"
    case features = "Features"
    case content = "Content"
    case performance = "Performance"
    case featureRequest = "Feature Request"
    case bug = "Bug Report"

    var id: String { rawValue }
}

private struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var rating: FeedbackRating = .great
    @State private var category: FeedbackCategory = .ui
    @State private var note: String = ""
    @State private var showSubmittedAlert = false

    var body: some View {
        Form {
            Section("Your Experience") {
                HStack {
                    FeedbackRatingButton(rating: .great, selectedRating: $rating)
                    FeedbackRatingButton(rating: .okay, selectedRating: $rating)
                    FeedbackRatingButton(rating: .bad, selectedRating: $rating)
                }
            }
            .font(.openSans(size: 16, weight: .semibold))

            Section("Category") {
                Picker("Category", selection: $category) {
                    ForEach(FeedbackCategory.allCases) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                .font(.openSans(size: 16))
            }
            .font(.openSans(size: 16, weight: .semibold))

            Section("Notes") {
                ZStack(alignment: .topLeading) {
                    if note.isEmpty {
                        Text(" Add any details you want to share…")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                        .font(.openSans(size: 16))
                }
                .font(.openSans(size: 16))
            }
            .font(.openSans(size: 16, weight: .semibold))

            Section {
                Button {
                    // TODO: Hook up to your feedback submission endpoint
                    showSubmittedAlert = true
                } label: {
                    Text("Submit Feedback")
                        .font(.openSans(size: 16))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thanks for your feedback!", isPresented: $showSubmittedAlert) {
            Button("Done") { dismiss() }
        } message: {
            Text("We appreciate you taking the time to help us improve.")
        }
    }
}

private struct FeedbackRatingButton: View {
    var rating: FeedbackRating
    @Binding var selectedRating: FeedbackRating

    @State private var isPulsing: Bool = false
    @State private var pulseTask: Task<Void, Never>?

    var isSelected: Bool { selectedRating == rating }

    var body: some View {
        Button {
            // update selection immediately
            selectedRating = rating

            // trigger a transient pulse animation: scale up then back to normal
            pulseTask?.cancel()
            pulseTask = Task {
                await MainActor.run {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                        isPulsing = true
                    }
                }
                // small delay for the pulse (250ms)
                try? await Task.sleep(nanoseconds: 250_000_000)
                await MainActor.run {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                        isPulsing = false
                    }
                }
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: rating.icon)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(isSelected ? rating.color : .secondary.opacity(0.4))
                Text(rating.rawValue)
                    .font(.openSans(size: 16, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.primary : .secondary.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? rating.color.opacity(0.12) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? rating.color : Color.secondary.opacity(0.4), lineWidth: 1)
                    )
            }
            // transient pulse on tap; returns to 1.0 after animation completes
            .scaleEffect(isPulsing ? 1.06 : 1.0)
            .shadow(color: Color.black.opacity(isPulsing ? 0.12 : 0.0), radius: isPulsing ? 8 : 0, x: 0, y: isPulsing ? 4 : 0)
            .contentShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
        .onDisappear {
            pulseTask?.cancel()
            pulseTask = nil
        }
    }
}

#Preview("Contact Support") {
    NavigationStack {
        ContactSupportView()
    }
    .loadCustomFonts()
}

#Preview("Feedback Form") {
    NavigationStack {
        FeedbackFormView()
    }
    .loadCustomFonts()
}
