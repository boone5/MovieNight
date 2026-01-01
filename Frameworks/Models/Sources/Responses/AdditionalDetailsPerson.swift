//
//  AdditionalDetailsPerson.swift
//  Models
//
//  Created by Ayren King on 12/24/25.
//

import Foundation

public struct AdditionalDetailsPerson: Codable, Equatable, Identifiable {
    public let id: Int64

    public let adult: Bool
    public let alsoKnownAs: [String]
    public let biography: String?
    public let birthday: String?
    public let deathDay: String?
    public let gender: PersonResponse.Gender
    public let knownForDepartment: String?
    public let name: String
    public let placeOfBirth: String?
    public let popularity: Double
    public let profilePath: String?

    public let credits: PersonCredits?

    enum CodingKeys: String, CodingKey {
        case id
        case adult
        case alsoKnownAs = "also_known_as"
        case biography
        case birthday
        case deathDay = "deathday"
        case gender
        case knownForDepartment = "known_for_department"
        case name
        case placeOfBirth = "place_of_birth"
        case popularity
        case profilePath = "profile_path"
        case credits = "combined_credits"
    }
}

extension AdditionalDetailsPerson {
    public struct PersonCredits: Codable, Equatable {
        public let cast: [PersonCastCredit]
        public let crew: [PersonCrewCredit]
    }
}

extension AdditionalDetailsPerson {
    public struct PersonCastCredit: Codable, Equatable, Identifiable {
        public var id: String { creditId }

        public let media: MediaResult

        public let character: String?
        public let creditId: String
        public let order: Int?

        enum CodingKeys: String, CodingKey {
            case media = "self"
            case character
            case creditId = "credit_id"
            case order
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.media = try MediaResult(from: decoder)
            self.character = try container.decodeIfPresent(String.self, forKey: .character)
            self.creditId = try container.decode(String.self, forKey: .creditId)
            self.order = try container.decodeIfPresent(Int.self, forKey: .order)
        }
    }
}

extension AdditionalDetailsPerson {
    public struct PersonCrewCredit: Codable, Equatable, Identifiable {
        public var id: String { creditId }

        public let media: MediaResult

        public let job: String?
        public let department: String?
        public let creditId: String

        enum CodingKeys: String, CodingKey {
            case media = "self"
            case job
            case department
            case creditId = "credit_id"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.media = try MediaResult(from: decoder)
            self.job = try container.decodeIfPresent(String.self, forKey: .job)
            self.department = try container.decodeIfPresent(String.self, forKey: .department)
            self.creditId = try container.decode(String.self, forKey: .creditId)
        }
    }
}

extension AdditionalDetailsPerson {
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    public var formattedBirthday: String? {
        let formatter = Self.dateFormatter
        guard let birthday, let date = formatter.date(from: birthday) else { return birthday }
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    public var formattedDeathDay: String? {
        let formatter = Self.dateFormatter
        guard let deathDay, let date = formatter.date(from: deathDay) else { return deathDay }
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    public var age: Int? {
        let formatter = Self.dateFormatter
        guard let birthday, let birthDate = formatter.date(from: birthday) else { return nil
        }
        let deathDay = self.deathDay.flatMap { formatter.date(from: $0) } ?? .now
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: deathDay)
        return ageComponents.year
    }
}
