//
//  PersonDetailsView.swift
//  Frameworks
//
//  Created by Ayren King on 12/28/25.
//

import Models
import SwiftUI
import UI

struct PersonDetailsView: View {
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
