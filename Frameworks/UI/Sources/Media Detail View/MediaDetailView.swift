//
//  MediaDetailView.swift
//  MovieNight
//
//  Created by Boone on 10/1/24.
//

import CoreData
import Dependencies
import Models
import Networking
import SwiftUI
import YouTubePlayerKit

// MARK: FilmDetailView

public struct MediaDetailView: View {
    @Environment(\.dismiss) var dismiss

    @State var viewModel: MediaDetailViewModel
    let navigationTransitionConfig: NavigationTransitionConfiguration<MediaItem.ID>
    let posterSize: CGSize

    @State private var showFullSummary = false
    @State private var actionTapped: QuickAction?
    @State private var watchCount = 0

    public init(
        media: MediaItem,
        navigationTransitionConfig: NavigationTransitionConfiguration<MediaItem.ID>,
    ) {
        _viewModel = State(wrappedValue: MediaDetailViewModel(media: media))
        self.navigationTransitionConfig = navigationTransitionConfig

        let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.bounds.size ?? .zero
        self.posterSize = CGSize(width: size.width / 1.5, height: size.height / 2.4)
    }

    var averageColor: Color {
        viewModel.averageColor
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 30) {
                // MARK: TODO
                // - Add gloss finish
                PosterView(
                    imagePath: viewModel.media.posterPath,
                    size: posterSize
                )
                .shadow(radius: 6, y: 3)
                .shimmyingEffect()
                .safeAreaPadding(.top, 50)

                VStack(alignment: .center, spacing: 5) {
                    Text(viewModel.media.title)
                        .font(.montserrat(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    switch viewModel.media.mediaType {
                    case .movie:
                        if case let .movie(details)? = viewModel.details {
                            Text(details.genres ?? "-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                            Text([details.releaseYear, details.duration].compactMap { $0 }.joined(separator: " · "))
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        } else {
                            Text("-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        }
                    case .tv:
                        if case let .tv(details)? = viewModel.details {
                            Text(details.genres ?? "-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                            Text([details.releaseYear, details.duration].compactMap { $0 }.joined(separator: " · "))
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        } else {
                            Text("-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        }
                    case .person:
                        if case let .person(personDetails)? = viewModel.details {
                            Text(personDetails.knownForDepartment ?? "-")
                                .font(.openSans(size: 12, weight: .regular))
                                .foregroundStyle(Color(uiColor: .systemGray2))
                        }
                    }
                }

                switch viewModel.media.mediaType {
                case .movie:
                    movieLayout()
                case .tv:
                    tvLayout()
                case .person:
                    if case let .person(details)? = viewModel.details {
                        personLayout(details)
                    } else {
                        Text("Uh oh")
                            .foregroundStyle(.white)
                        LoadingIndicator()
                    }
                }

                Spacer()
            }
            .padding(.vertical, 80)
            .padding(.horizontal, 20)
        }
        .background {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(
                    LinearGradient(
                        colors: [viewModel.averageColor, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) {
            toolbar
        }
        .task(id: "fetchInitialData") {
            await viewModel.loadInitialData()
        }
        .zoomTransition(configuration: navigationTransitionConfig)
    }
}

extension MediaDetailView {
    private var toolbar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark")
                    .foregroundStyle(Color.ivoryWhite.opacity(0.8))
                    .labelStyle(.iconOnly)
                    .frame(width: 50, height: 50)
            }
            .glassEffect(.regular.tint(averageColor.opacity(0.8)).interactive(), in: .circle)

            Spacer()

            Menu {
                ForEach(viewModel.menuSections) { section in
                    ForEach(section.actions) { action in
                        Button(role: action.role == .destructive ? .destructive : nil) {
                            action.handler()
                        } label: {
                            Label(action.title, systemImage: action.systemImage)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color.ivoryWhite.opacity(0.8))
                    .labelStyle(.iconOnly)
                    .frame(width: 50, height: 50)
                    .glassEffect(.regular.tint(averageColor.opacity(0.8)).interactive(), in: .circle)
                    .clipShape(.circle)
            }
        }
        .safeAreaPadding(.horizontal)
    }

    @ViewBuilder
    private func personDetails(_ details: AdditionalDetailsPerson) -> some View {
        PersonDetailsView(details: details, averageColor: averageColor)
    }

    @ViewBuilder
    private func movieLayout() -> some View {
        FeedbackButtons(feedback: $viewModel.media.feedback, averageColor: viewModel.averageColor) {
            viewModel.addActivity(feedback: $0)
        }

        if let summary = viewModel.media.overview {
            Card(averageColor: averageColor) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Summary")
                        .font(.montserrat(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(summary)
                        .font(.openSans(size: 14))
                        .foregroundStyle(.white)
                        .truncationEffect(length: 5, isEnabled: !showFullSummary, animation: .smooth(duration: 0.5, extraBounce: 0))

                    Button(showFullSummary ? "Read less" : "Read more") {
                        showFullSummary.toggle()
                    }
                    .font(.openSans(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }

        CommentPromptView(
            averageColor: viewModel.averageColor,
            comments: viewModel.media.comments ?? [],
            didTapSave: { comment in
                viewModel.addComment(text: comment)
            }
        )

        QuickActionsView(
            mediaType: .movie,
            averageColor: viewModel.averageColor,
            actionTapped: $actionTapped
        )

        if let actionTapped {
            switch actionTapped {
            case .collection:
                ActionView(averageColor: averageColor) {
                    HStack {
                        Text(actionTapped.longTitle)
                            .font(.openSans(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Spacer()

                        Label {
                            Text("Add a collection")
                                .font(.openSans(size: 14))
                        } icon: {
                            Image(systemName: "plus")
                                .font(.openSans(size: 14))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .background(averageColor.opacity(0.4))
                        .cornerRadius(12)
                    }
                }
            case .location:
                WatchedAtView(averageColor: viewModel.averageColor)
            case .watchCount:
                ActionView(averageColor: averageColor) {
                    HStack(spacing: 0) {
                        Text(actionTapped.longTitle + " \(watchCount) times")
                            .font(.openSans(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Spacer()

                        CustomStepper(steps: 10, startStep: $watchCount)
                    }
                    .padding(.vertical, 10)
                }
            case .watchedWith:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            case .occasion:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            case .seasonsWatched, .favoriteSeason, .favoriteEpisode:
                EmptyView()
            }
        }

        if case let .movie(details)? = viewModel.details, let cast = details.cast {
            CastScrollView(averageColor: viewModel.averageColor, cast: cast)
        }

        if case let .movie(details)? = viewModel.details, let trailer = details.trailer, let key = trailer.key {
            VStack(alignment: .leading, spacing: 20) {
                Text("Trailer")
                    .font(.montserrat(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                TrailerView(videoID: key)
            }
            .padding(20)
            .background(averageColor.opacity(0.4))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private func tvLayout() -> some View {
        FeedbackButtons(feedback: $viewModel.media.feedback, averageColor: viewModel.averageColor) {
            viewModel.addActivity(feedback: $0)
        }

        if let summary = viewModel.media.overview {
            Card(averageColor: averageColor) {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Summary")
                        .font(.montserrat(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(summary)
                        .font(.openSans(size: 14))
                        .foregroundStyle(.white)
                        .truncationEffect(length: 5, isEnabled: !showFullSummary, animation: .smooth(duration: 0.5, extraBounce: 0))

                    Button(showFullSummary ? "Read less" : "Read more") {
                        showFullSummary.toggle()
                    }
                    .font(.openSans(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }

        CommentPromptView(
            averageColor: viewModel.averageColor,
            comments: viewModel.media.comments ?? [],
            didTapSave: { comment in
                viewModel.addComment(text: comment)
            }
        )

        QuickActionsView(
            mediaType: .tv,
            averageColor: viewModel.averageColor,
            actionTapped: $actionTapped
        )

        if let actionTapped {
            switch actionTapped {
            case .collection:
                ActionView(averageColor: averageColor) {
                    HStack {
                        Text(actionTapped.longTitle)
                            .font(.openSans(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Label {
                            Text("Add a collection")
                                .font(.openSans(size: 14))
                        } icon: {
                            Image(systemName: "plus")
                                .font(.openSans(size: 14))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .background(averageColor.opacity(0.4))
                        .cornerRadius(12)
                    }
                }
            case .location:
                WatchedAtView(averageColor: viewModel.averageColor)
            case .watchCount:
                ActionView(averageColor: averageColor) {
                    HStack(spacing: 0) {
                        Text(actionTapped.longTitle + " \(watchCount) times")
                            .font(.openSans(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        CustomStepper(steps: 10, startStep: $watchCount)
                    }
                    .padding(.vertical, 10)
                }
            case .watchedWith:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            case .occasion:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            case .seasonsWatched:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            case .favoriteSeason:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            case .favoriteEpisode:
                ActionView(averageColor: averageColor) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }

        if case let .tv(details)? = viewModel.details {
            SeasonsScrollView(viewModel: viewModel)
            if let cast = details.cast {
                CastScrollView(averageColor: viewModel.averageColor, cast: cast)
            }
            if let trailer = details.trailer, let key = trailer.key {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Trailer")
                        .font(.montserrat(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    TrailerView(videoID: key)
                }
                .padding(20)
                .background(averageColor.opacity(0.4))
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private func personLayout(_ details: AdditionalDetailsPerson) -> some View {
        PersonDetailsView(details: details, averageColor: averageColor)

        // Person-specific quick actions with placeholder handlers
        QuickActionsView(
            mediaType: .person,
            averageColor: viewModel.averageColor,
            actionTapped: $actionTapped
        )

        if let actionTapped {
            ActionView(averageColor: averageColor) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(actionTapped.longTitle)
                        .font(.openSans(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("This action will be available soon.")
                        .font(.openSans(size: 13))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }
}

// MARK: - Person Details

private struct PersonDetailsView: View {
    let details: AdditionalDetailsPerson
    let averageColor: Color

    @State private var showFullBio = false

    var body: some View {
        VStack(spacing: 20) {
            if let bio = details.biography, bio.isEmpty == false {
                Card(averageColor: averageColor) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bio")
                            .font(.montserrat(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(bio)
                            .font(.openSans(size: 14))
                            .foregroundStyle(.white)
                            .truncationEffect(length: 5, isEnabled: !showFullBio, animation: .smooth(duration: 0.5, extraBounce: 0))

                        Button(showFullBio ? "Read less" : "Read more") {
                            showFullBio.toggle()
                        }
                        .font(.openSans(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Card(averageColor: averageColor) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personal Info")
                        .font(.montserrat(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    if let knownFor = details.knownForDepartment, knownFor.isEmpty == false {
                        infoLabel(title: "Known for", detail: knownFor)
                    }

                    infoLabel(title: "Gender", detail: genderString(details.gender))

                    if let birthday = formattedDate(details.birthday) {
                        let age = computeAge(from: details.birthday, to: details.deathDay)
                        let suffix = age.map { " (" + String($0) + " years)" } ?? ""
                        infoLabel(title: "Birthday", detail: birthday + suffix)
                    }

                    if let deathday = formattedDate(details.deathDay) {
                        infoLabel(title: "Died", detail: deathday)
                    }

                    if let pob = details.placeOfBirth, pob.isEmpty == false {
                        infoLabel(title: "Place of birth", detail: pob)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let cast = details.credits?.cast, cast.isEmpty == false {
                FilmographySection(title: "Acting", credits: cast.map { .cast($0) }, averageColor: averageColor)
            }

            if let crew = details.credits?.crew, crew.isEmpty == false {
                FilmographySection(title: "Crew", credits: crew.map { .crew($0) }, averageColor: averageColor)
            }
        }
    }

    // Reusable info row used in Personal Info card
    @ViewBuilder
    func infoLabel(title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.openSans(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 110, alignment: .leading)
            Text(detail)
                .font(.openSans(size: 13))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Helpers

    private func genderString(_ gender: PersonResponse.Gender) -> String {
        switch gender {
        case .female: return "Female"
        case .male: return "Male"
        case .nonBinary: return "Non-binary"
        case .notSpecified: return "Not specified"
        }
    }

    private func formattedDate(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: raw) else { return raw }
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func computeAge(from birthday: String?, to deathday: String?) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let b = birthday, let birthDate = formatter.date(from: b) else { return nil }
        let endDate: Date = {
            if let d = deathday, let deathDate = formatter.date(from: d) { return deathDate }
            return Date()
        }()
        let components = Calendar.current.dateComponents([.year], from: birthDate, to: endDate)
        return components.year
    }
}

private struct FilmographySection: View {
    enum Credit: Identifiable {
        case cast(AdditionalDetailsPerson.PersonCastCredit)
        case crew(AdditionalDetailsPerson.PersonCrewCredit)

        var id: String {
            switch self {
            case .cast(let c): return c.id
            case .crew(let c): return c.id
            }
        }

        var media: MediaResult {
            switch self {
            case .cast(let c): return c.media
            case .crew(let c): return c.media
            }
        }

        var subtitle: String? {
            switch self {
            case .cast(let c): return c.character
            case .crew(let c): return c.job
            }
        }
    }

    let title: String
    let credits: [Credit]
    let averageColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.montserrat(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(credits) { credit in
                        FilmographyItem(credit: credit)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}

private struct FilmographyItem: View {
    let credit: FilmographySection.Credit
    @Namespace private var namespace

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ThumbnailView(
                media: .init(from: credit.media),
                size: .init(width: 120, height: 180),
                transitionConfig: .init(namespace: namespace, source: .init(from: credit.media))
            )
            .clipShape(.rect(cornerRadius: 8))

            Text(credit.media.title)
                .font(.openSans(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)

            if let sub = credit.subtitle, sub.isEmpty == false {
                Text(sub)
                    .font(.openSans(size: 11))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .frame(width: 120, alignment: .leading)
            }
        }
    }
}

public struct Card<Content: View>: View {
    let averageColor: Color
    let content: () -> Content

    public init(averageColor: Color, @ViewBuilder content: @escaping () -> Content) {
        self.averageColor = averageColor
        self.content = content
    }

    public var body: some View {
        VStack {
            content()
        }
        .padding(20)
        .background(averageColor.opacity(0.4))
        .cornerRadius(12)
    }
}

// MARK: Preview

#Preview {
    @Previewable @Namespace var namespace

    let _ = prepareDependencies {
        $0.imageLoader = .liveValue
        $0.networkClient.fetchPersonDetails = { _ in
            if let person = AdditionalDetailsPerson.mock() {
                return person
            } else {
                throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode mock JSON"])
            }
        }
    }

//    let film: MediaItem = .init(from: .movie(MovieResponse()))
//    let film: ResponseType = ResponseType.tvShow(TVShowResponse())
    let item = MediaItem(
        from:
                .person(
                    .init(
                        id: 0,
                        adult: true,
                        name: "Jeremy Renner",
                        originalName: nil,
                        mediaType: .person,
                        popularity: nil,
                        gender: .male,
                        knownForDepartment: "Acting",
                        profilePath: "/yB84D1neTYXfWBaV0QOE9RF2VCu.jpg",
                        character: nil,
                        knownFor: []
                    )
                )
    )

    Text("FilmDetailView Preview")
        .fullScreenCover(isPresented: .constant(true)) {
            MediaDetailView(media: item, navigationTransitionConfig: .init(namespace: namespace, source: item))
                .loadCustomFonts()
        }
}


extension AdditionalDetailsPerson {
    static func mock() -> AdditionalDetailsPerson? {
        let data = Data(mockJSON.utf8)
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(AdditionalDetailsPerson.self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }


    static var mockJSON: String {
        """
        {\r\n  \"place_of_birth\": \"Modesto, California, USA\",\r\n  \"profile_path\": \"/yB84D1neTYXfWBaV0QOE9RF2VCu.jpg\",\r\n  \"id\": 17604,\r\n  \"gender\": 2,\r\n  \"adult\": false,\r\n  \"also_known_as\": [\"Jeremy Lee Renner\"],\r\n  \"name\": \"Jeremy Renner\",\r\n  \"biography\": \"Jeremy Lee Renner (born January 7, 1971) is an American actor.\\n\\nHe began his career by appearing in independent films such as Dahmer (2002) and Neo Ned (2005). Renner earned supporting roles in bigger films, such as S.W.A.T. (2003) and 28 Weeks Later (2007).\\n\\nRenner was nominated for the Academy Award for Best Actor for his performance in The Hurt Locker (2008) and for the Academy Award for Best Supporting Actor for his performance in The Town (2010).\\n\\nRenner played Clint Barton / Hawkeye in the Marvel Cinematic Universe films Thor (2011), The Avengers (2012), Avengers: Age of Ultron (2015), Captain America: Civil War (2016), Avengers: Endgame (2019), and Black Widow (2021) in an uncredited voice cameo; with a further appearance in the Disney+ show Hawkeye (2021). He also appeared in Mission: Impossible – Ghost Protocol (2011), The Bourne Legacy (2012), Hansel and Gretel: Witch Hunters (2013), American Hustle (2013), Mission: Impossible – Rogue Nation (2015), and Arrival (2016).\",\r\n  \"birthday\": \"1971-01-07\",\r\n  \"popularity\": 5.8028,\r\n  \"combined_credits\": {\r\n    \"crew\": [\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"A reporter becomes the target of a vicious smear campaign that drives him to the point of suicide after he exposes the CIA\'s role in arming Contra rebels in Nicaragua and importing cocaine into California. Based on the true story of journalist Gary Webb.\",\r\n          \"original_title\": \"Kill the Messenger\",\r\n          \"vote_average\": 6.617,\r\n          \"title\": \"Kill the Messenger\",\r\n          \"video\": false,\r\n          \"release_date\": \"2014-10-09\",\r\n          \"poster_path\": \"/8gaNZiKZHvKCqMDByY00dUIV0YC.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 891,\r\n          \"backdrop_path\": \"/hYVAvYJXE4taTIh2y6F5mGJWfPm.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 245916,\r\n          \"popularity\": 10.4855,\r\n          \"genre_ids\": [80, 18, 9648, 53, 36],\r\n        \"job\": \"Producer\",\r\n        \"department\": \"Production\",\r\n        \"credit_id\": \"52fe4f0dc3a36847f82b9e83\"\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"The true story of how Ray Kroc, a salesman from Illinois, met Mac and Dick McDonald, who were running a burger operation in 1950s Southern California. Kroc was impressed by the brothers’ speedy system of making the food and saw franchise potential. He maneuvered himself into a position to be able to pull the company from the brothers and create a billion-dollar empire.\",\r\n          \"original_title\": \"The Founder\",\r\n          \"vote_average\": 7.135,\r\n          \"title\": \"The Founder\",\r\n          \"video\": false,\r\n          \"release_date\": \"2016-11-24\",\r\n          \"poster_path\": \"/8gLIksu5ggdfBL1UbeTeonHquxl.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 5246,\r\n          \"backdrop_path\": \"/5WparwIlAtSZW0tcWbK2NHEZJC6.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 310307,\r\n          \"popularity\": 4.8433,\r\n          \"genre_ids\": [18, 36],\r\n        \"job\": \"Producer\",\r\n        \"department\": \"Production\",\r\n        \"credit_id\": \"584627c99251416a7401c627\"\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Notorious hacker Drew Reynolds is captured by the CIA and given a proposition - work for them or spend the rest of his life in prison. Agreeing on the condition that he can form his own team, he puts together a group of \\\"throwaways\\\" - the people deemed expendable and seemingly the worst in the organization.\",\r\n          \"original_title\": \"The Throwaways\",\r\n          \"vote_average\": 5.4,\r\n          \"title\": \"The Throwaways\",\r\n          \"video\": false,\r\n          \"release_date\": \"2015-01-30\",\r\n          \"poster_path\": \"/1265SilA4N4Q09SAnKguZjbuARJ.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 71,\r\n          \"backdrop_path\": \"/1BOrGO9c86ctTeZxECYsmoxHwjL.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 321621,\r\n          \"popularity\": 3.9535,\r\n          \"genre_ids\": [28, 53, 14],\r\n        \"job\": \"Executive Producer\",\r\n        \"department\": \"Production\",\r\n        \"credit_id\": \"602f74433e6f2b003f061009\"\r\n      },\r\n      {\r\n          \"original_name\": \"Knightfall\",\r\n          \"media_type\": \"tv\",\r\n          \"name\": \"Knightfall\",\r\n          \"overview\": \"Go deep into the clandestine world of the legendary brotherhood of warrior monks known as The Knights Templar.\",\r\n          \"vote_average\": 7.005,\r\n          \"first_air_date\": \"2017-12-06\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/5T3VJOF4ti3ep6JXqSgyzSGdv0h.jpg\",\r\n          \"origin_country\": [\"US\"],\r\n          \"vote_count\": 332,\r\n          \"backdrop_path\": \"/aKYAuHyDIGnIAd35UAv1cpYWPWL.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 73117,\r\n          \"popularity\": 4.8755,\r\n          \"genre_ids\": [10759, 18],\r\n        \"job\": \"Executive Producer\",\r\n        \"department\": \"Production\",\r\n        \"credit_id\": \"602f746164f716003f561760\"\r\n      },\r\n      {\r\n          \"original_name\": \"Mayor of Kingstown\",\r\n          \"media_type\": \"tv\",\r\n          \"name\": \"Mayor of Kingstown\",\r\n          \"overview\": \"In a small Michigan town where the business of incarceration is the only thriving industry, the McClusky family are the power brokers between the police, criminals, inmates, prison guards and politicians in a city completely dependent on prisons and the prisoners they contain.\",\r\n          \"vote_average\": 7.868,\r\n          \"first_air_date\": \"2021-11-14\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/6rWIip9MZELAA0SKii5WqsBDCYW.jpg\",\r\n          \"origin_country\": [\"US\"],\r\n          \"vote_count\": 551,\r\n          \"backdrop_path\": \"/39bifj2FNytJ2m1cqOBcWMTKgmV.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 97951,\r\n          \"popularity\": 48.7651,\r\n          \"genre_ids\": [18, 80],\r\n        \"job\": \"Executive Producer\",\r\n        \"department\": \"Production\",\r\n        \"credit_id\": \"6037537aeec5b5003c1c4473\"\r\n      },\r\n      {\r\n          \"original_name\": \"Rennervations\",\r\n          \"media_type\": \"tv\",\r\n          \"name\": \"Rennervations\",\r\n          \"overview\": \"This four-part series embraces Jeremy Renner\'s lifelong passion for giving back to communities around the world by reimagining unique purpose-built vehicles to meet a community’s needs.\",\r\n          \"vote_average\": 7.9,\r\n          \"first_air_date\": \"2023-04-12\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/kZtmwqjAi0rtgXIjbMmH1vcQWlD.jpg\",\r\n          \"origin_country\": [\"US\"],\r\n          \"vote_count\": 11,\r\n          \"backdrop_path\": \"/6j716XgRVraH9snx76JbhFtLdwW.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 157212,\r\n          \"popularity\": 1.132,\r\n          \"genre_ids\": [99, 10764],\r\n        \"job\": \"Executive Producer\",\r\n        \"department\": \"Production\",\r\n        \"credit_id\": \"62017aa2ae366800982d4502\"\r\n      }\r\n    ],\r\n    \"cast\": [\r\n      {\r\n        \"order\": 2,\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Twenty-eight weeks after the spread of a deadly rage virus, the inhabitants of the British Isles have lost their battle against the onslaught, as the virus has killed everyone there. Six months later, a group of Americans dare to set foot on the Isles, convinced the danger has passed. But it soon becomes all too clear that the scourge continues to live, waiting to pounce on its next victims.\",\r\n          \"original_title\": \"28 Weeks Later\",\r\n          \"vote_average\": 6.607,\r\n          \"title\": \"28 Weeks Later\",\r\n          \"video\": false,\r\n          \"release_date\": \"2007-04-26\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/oix0aNv1lvW3nUGspUyvSIBlpbs.jpg\",\r\n          \"vote_count\": 5220,\r\n          \"backdrop_path\": \"/83ownpZPvBHJD5UVNShzQfa3LaW.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 1562,\r\n          \"popularity\": 7.4645,\r\n          \"genre_ids\": [27, 53, 878],\r\n        \"character\": \"Sergeant Doyle\",\r\n        \"credit_id\": \"52fe42fec3a36847f8032555\"\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Against his father Odin\'s will, The Mighty Thor - a powerful but arrogant warrior god - recklessly reignites an ancient war. Thor is cast down to Earth and forced to live among humans as punishment. Once here, Thor learns what it takes to be a true hero when the most dangerous villain of his world sends the darkest forces of Asgard to invade Earth.\",\r\n          \"original_title\": \"Thor\",\r\n          \"vote_average\": 6.768,\r\n          \"title\": \"Thor\",\r\n          \"video\": false,\r\n          \"release_date\": \"2011-04-21\",\r\n          \"poster_path\": \"/prSfAi1xGrhLQNxVSUFh61xQ4Qy.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 21930,\r\n          \"backdrop_path\": \"/cDJ61O1STtbWNBwefuqVrRe3d7l.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 10195,\r\n          \"popularity\": 11.0239,\r\n          \"genre_ids\": [12, 14, 28],\r\n        \"character\": \"Clint Barton / Hawkeye (uncredited)\",\r\n        \"credit_id\": \"52fe433f9251416c75009265\",\r\n        \"order\": 50\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Outlaw Jesse James is rumored to be the \'fastest gun in the West\'. An eager recruit into James\' notorious gang, Robert Ford eventually grows jealous of the famed outlaw and, when Robert and his brother sense an opportunity to kill James, their murderous action elevates their target to near mythical status.\",\r\n          \"original_title\": \"The Assassination of Jesse James by the Coward Robert Ford\",\r\n          \"vote_average\": 7,\r\n          \"title\": \"The Assassination of Jesse James by the Coward Robert Ford\",\r\n          \"video\": false,\r\n          \"release_date\": \"2007-09-20\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/xMKn6EQS7eR5ubhPJbw5pQSBZMw.jpg\",\r\n          \"vote_count\": 2673,\r\n          \"backdrop_path\": \"/5r2BZajlRZqnOc6s2BS0aiFDcne.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 4512,\r\n          \"popularity\": 3.3979,\r\n          \"genre_ids\": [18, 37],\r\n        \"character\": \"Wood Hite\",\r\n        \"credit_id\": \"52fe43c7c3a36847f806ef47\",\r\n        \"order\": 4\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Doug MacRay is a longtime thief, who, smarter than the rest of his crew, is looking for his chance to exit the game. When a bank job leads to the group kidnapping an attractive branch manager, he takes on the role of monitoring her – but their burgeoning relationship threatens to unveil the identities of Doug and his crew to the FBI Agent who is on their case.\",\r\n          \"original_title\": \"The Town\",\r\n          \"vote_average\": 7.216,\r\n          \"title\": \"The Town\",\r\n          \"video\": false,\r\n          \"release_date\": \"2010-09-15\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/3NIzyXkfylsjflRKSz8Fts3lXzm.jpg\",\r\n          \"vote_count\": 5398,\r\n          \"backdrop_path\": \"/owAe5rRStnX7ibVAPmza3NCXjCy.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 23168,\r\n          \"popularity\": 6.0793,\r\n          \"genre_ids\": [80, 18, 53],\r\n        \"character\": \"James \\\"Jem\\\" Coughlin\",\r\n        \"credit_id\": \"52fe4461c3a368484e01fab1\",\r\n        \"order\": 1\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"When an unexpected enemy emerges and threatens global safety and security, Nick Fury, director of the international peacekeeping agency known as S.H.I.E.L.D., finds himself in need of a team to pull the world back from the brink of disaster. Spanning the globe, a daring recruitment effort begins!\",\r\n          \"original_title\": \"The Avengers\",\r\n          \"vote_average\": 7.882,\r\n          \"title\": \"The Avengers\",\r\n          \"video\": false,\r\n          \"release_date\": \"2012-04-25\",\r\n          \"poster_path\": \"/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 34586,\r\n          \"backdrop_path\": \"/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 24428,\r\n          \"popularity\": 49.8791,\r\n          \"genre_ids\": [878, 28, 12],\r\n        \"character\": \"Clint Barton / Hawkeye\",\r\n        \"credit_id\": \"52fe4495c3a368484e02b225\",\r\n        \"order\": 5\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"During the Iraq War, a Sergeant recently assigned to an army bomb squad is put at odds with his squad mates due to his maverick way of handling his work.\",\r\n          \"original_title\": \"The Hurt Locker\",\r\n          \"vote_average\": 7.256,\r\n          \"title\": \"The Hurt Locker\",\r\n          \"video\": false,\r\n          \"release_date\": \"2008-10-10\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/io2dfBJhasvGbgkCX9cCGVOiA99.jpg\",\r\n          \"vote_count\": 5950,\r\n          \"backdrop_path\": \"/nKieVGBCZQfcylwO7mOMPaug8f2.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 12162,\r\n          \"popularity\": 5.6034,\r\n          \"genre_ids\": [18, 53, 10752],\r\n        \"character\": \"Staff Sergeant William James\",\r\n        \"credit_id\": \"52fe44c29251416c7503fef1\",\r\n        \"order\": 0\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Hondo Harrelson recruits Jim Street to join an elite unit of the Los Angeles Police Department. Together they seek out more members, including tough Deke Kay and single mom Chris Sanchez. The team\'s first big assignment is to escort crime boss Alex Montel to prison. It seems routine, but when Montel offers a huge reward to anyone who can break him free, criminals of various stripes step up for the prize.\",\r\n          \"original_title\": \"S.W.A.T.\",\r\n          \"vote_average\": 6.159,\r\n          \"title\": \"S.W.A.T.\",\r\n          \"video\": false,\r\n          \"release_date\": \"2003-08-08\",\r\n          \"poster_path\": \"/bon63yPVIgUFLP2653Dg9GCOJLJ.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 2622,\r\n          \"backdrop_path\": \"/dfSAFTqNLfB3YAs9Ppy13EUaNYI.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 9257,\r\n          \"popularity\": 3.7016,\r\n          \"genre_ids\": [28, 53, 80],\r\n        \"character\": \"Brian Gamble\",\r\n        \"credit_id\": \"52fe44ddc3a36847f80aea87\",\r\n        \"order\": 5\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"On February 15, 1992 in Milwaukee, Wisconsin, Jeffrey Dahmer, one of the world\'s most infamous serial killers, was convicted of 15 counts of murder and sentenced to 937 years in federal prison. This movie is based on events from his life.\",\r\n          \"original_title\": \"Dahmer\",\r\n          \"vote_average\": 5.273,\r\n          \"title\": \"Dahmer\",\r\n          \"video\": false,\r\n          \"release_date\": \"2002-06-21\",\r\n          \"poster_path\": \"/gZPrXBXYf2s4VztHdQpd0441jF6.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 317,\r\n          \"backdrop_path\": \"/bypraAsU9NdFm3HXWYLBKPlipke.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 25853,\r\n          \"popularity\": 3.8314,\r\n          \"genre_ids\": [80, 18, 53, 27],\r\n        \"character\": \"Jeffrey Dahmer\",\r\n        \"credit_id\": \"52fe44e0c3a368484e03bef3\",\r\n        \"order\": 0\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Young Jeremiah lives in a stable environment with loving foster parents until the day his troubled mother, Sarah, returns to claim him. Jeremiah becomes swept up in his mother\'s dangerous world of drugs, seedy hotels, strip joints and revolving lovers. Salvation comes in the form of the boy\'s ultrareligious grandparents, but soon Jeremiah\'s mother returns. Maternal love binds the pair together on the road until Sarah\'s desperate and depraved lifestyle finally consumes her.\",\r\n          \"original_title\": \"The Heart Is Deceitful Above All Things\",\r\n          \"vote_average\": 5.8,\r\n          \"title\": \"The Heart Is Deceitful Above All Things\",\r\n          \"video\": false,\r\n          \"release_date\": \"2004-09-15\",\r\n          \"poster_path\": \"/gf5wCcEvCPhpLFZkY68aLzMNAfC.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 154,\r\n          \"backdrop_path\": \"/kfjHG9n155YsOVwGKciB7q8KPAe.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 26579,\r\n          \"popularity\": 0.7626,\r\n          \"genre_ids\": [18],\r\n        \"character\": \"Emerson\",\r\n        \"credit_id\": \"52fe450bc3a368484e0454ff\",\r\n        \"order\": 2\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"An animated reimaging of the largest wildfire evacuation in Alberta\'s history, with upwards of 88,000 people forced from their homes.\",\r\n          \"original_title\": \"Back Home Again\",\r\n          \"vote_average\": 7,\r\n          \"title\": \"Back Home Again\",\r\n          \"video\": false,\r\n          \"release_date\": \"2021-10-28\",\r\n          \"poster_path\": \"/cjxtmEOY8QBR5v5BuBrVccR7fWZ.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 1,\r\n          \"backdrop_path\": \"/4i7XPVCpIM5Dd6jeowh3jyqCAvc.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 894203,\r\n          \"popularity\": 0.3656,\r\n          \"genre_ids\": [16, 18, 10751],\r\n        \"character\": \"Lieutenant Timber (voice)\",\r\n        \"credit_id\": \"61840ecbddd52d0061614445\",\r\n        \"order\": 3\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"A fictionalized account of the first major successful sexual harassment case in the United States — Jenson vs. Eveleth Mines, where a woman who endured a range of abuse while working as a miner filed and won the landmark 1984 lawsuit.\",\r\n          \"original_title\": \"North Country\",\r\n          \"vote_average\": 7.232,\r\n          \"title\": \"North Country\",\r\n          \"video\": false,\r\n          \"release_date\": \"2005-02-12\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/upxUN4zmX79o49mBW9htKZDeNq7.jpg\",\r\n          \"vote_count\": 709,\r\n          \"backdrop_path\": \"/6rgiRuLHn65d3qalkc7YjrtmDQW.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 9701,\r\n          \"popularity\": 5.3223,\r\n          \"genre_ids\": [18],\r\n        \"character\": \"Bobby Sharp\",\r\n        \"credit_id\": \"52fe451ec3a36847f80bd813\",\r\n        \"order\": 4\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Explore the Disney+ series of the MCU—past, present and future!\",\r\n          \"original_title\": \"Marvel Studios\' 2021 Disney+ Day Special\",\r\n          \"vote_average\": 6.9,\r\n          \"title\": \"Marvel Studios\' 2021 Disney+ Day Special\",\r\n          \"video\": false,\r\n          \"release_date\": \"2021-11-12\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/zh0B5DDP93e3zokktb5aHHfIh01.jpg\",\r\n          \"vote_count\": 31,\r\n          \"backdrop_path\": \"/rLnv5QXUE3ITZTfrobsfXuAUtG.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 877188,\r\n          \"popularity\": 1.2121,\r\n          \"genre_ids\": [99],\r\n        \"character\": \"Clint Barton / Hawkeye (archive footage)\",\r\n        \"credit_id\": \"618f6a11a313b80042e29995\",\r\n        \"order\": 7\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"While on detention, a group of misfits and slackers have to write a letter to the President explaining what is wrong with the education system. There is only one problem, the President loves it! Hence, the group must travel to Washington to meet the Main Man.\",\r\n          \"original_title\": \"National Lampoon\'s Senior Trip\",\r\n          \"vote_average\": 5.4,\r\n          \"title\": \"National Lampoon\'s Senior Trip\",\r\n          \"video\": false,\r\n          \"release_date\": \"1995-09-08\",\r\n          \"poster_path\": \"/3QpB4KpMKRnZnsJOsemOZHDoQKw.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 99,\r\n          \"backdrop_path\": \"/4ZBhKQ4ar6sIOG2greomg2e3dv2.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 27993,\r\n          \"popularity\": 1.0114,\r\n          \"genre_ids\": [35],\r\n        \"character\": \"Dags\",\r\n        \"credit_id\": \"52fe4572c3a368484e05b697\",\r\n        \"order\": 4\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"The lives of two strangers - a struggling mother and a gambling addict - meet in tragedy. Years pass, and they must come to terms with themselves, and one another.\",\r\n          \"original_title\": \"Take\",\r\n          \"vote_average\": 5.3,\r\n          \"title\": \"Take\",\r\n          \"video\": false,\r\n          \"release_date\": \"2008-07-25\",\r\n          \"poster_path\": \"/iHpPFevxOBi5Czwd1VN5AWQKh5q.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 29,\r\n          \"backdrop_path\": \"/pLBvz8nVHOowZQfPH89Wn32dGKV.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 13941,\r\n          \"popularity\": 2.6576,\r\n          \"genre_ids\": [80, 18, 53],\r\n        \"character\": \"Saul\",\r\n        \"credit_id\": \"52fe45b79251416c7505fff3\",\r\n        \"order\": 1\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"Jeremy Renner sits down with Diane Sawyer for his first television interview since the critical snow plow accident that nearly cost him his life.\",\r\n          \"original_title\": \"Jeremy Renner: The Diane Sawyer Interview - A Story of Terror, Survival and Triumph\",\r\n          \"vote_average\": 9.3,\r\n          \"title\": \"Jeremy Renner: The Diane Sawyer Interview - A Story of Terror, Survival and Triumph\",\r\n          \"video\": false,\r\n          \"release_date\": \"2023-04-06\",\r\n          \"poster_path\": \"/8W8fb4Maw6b7uw3iBMj0HRNSfAZ.jpg\",\r\n          \"original_language\": \"en\",\r\n          \"vote_count\": 3,\r\n          \"backdrop_path\": \"/fvEUf5EtWnhhOyKJFx4dxbyzMiF.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 1106227,\r\n          \"popularity\": 0.1498,\r\n          \"genre_ids\": [99, 10770],\r\n        \"character\": \"Self - Interviewee\",\r\n        \"credit_id\": \"6424502d960cde009a95ce7f\",\r\n        \"order\": 1\r\n      },\r\n      {\r\n          \"media_type\": \"movie\",\r\n          \"overview\": \"After getting a taste for blood as children, Hansel and Gretel have become the ultimate vigilantes, hell-bent on retribution. Now, unbeknownst to them, Hansel and Gretel have become the hunted, and must face an evil far greater than witches... their past.\",\r\n          \"original_title\": \"Hansel & Gretel: Witch Hunters\",\r\n          \"vote_average\": 6.094,\r\n          \"title\": \"Hansel & Gretel: Witch Hunters\",\r\n          \"video\": false,\r\n          \"release_date\": \"2013-01-17\",\r\n          \"original_language\": \"en\",\r\n          \"poster_path\": \"/j343Rpj3WeNvP0SV80zveve70io.jpg\",\r\n          \"vote_count\": 6963,\r\n          \"backdrop_path\": \"/mJSe5dxKu8Sq0GfdjdWVqdGvzfV.jpg\",\r\n          \"adult\": false,\r\n          \"id\": 60304,\r\n          \"popularity\": 4.6358,\r\n          \"genre_ids\": [14, 27, 28],\r\n        \"character\": \"Hansel\",\r\n        \"credit_id\": \"52fe461fc3a368484e07ff71\",\r\n        \"order\": 0\r\n      }\r\n    ]\r\n  },\r\n  \"known_for_department\": \"Acting\"\r\n}\r\n
        """
    }
}
