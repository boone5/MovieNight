//
//  CreditsResponse.swift
//  Frameworks
//
//  Created by Ayren King on 12/24/25.
//

public struct CreditsResponse: Codable, Hashable {
    public let cast: [CastCredit]
    public let crew: [CrewCredit]
}

extension CreditsResponse {
    public struct PersonCore: Codable, Hashable, Identifiable {
        public let id: Int64
        public let adult: Bool
        public let name: String
        public let originalName: String?
        public let popularity: Double
        public let gender: PersonResponse.Gender
        public let knownForDepartment: String?
        public let profilePath: String?

        enum CodingKeys: String, CodingKey {
            case id
            case adult
            case name
            case originalName = "original_name"
            case popularity
            case gender
            case knownForDepartment = "known_for_department"
            case profilePath = "profile_path"
        }
    }
}


public struct CastCredit: Codable, Hashable, Identifiable {
    public let person: CreditsResponse.PersonCore

    public let castId: Int?
    public let character: String?
    public let creditId: String
    public let order: Int?

    // MARK: - Identifiable
    public var id: String { creditId }

    enum CodingKeys: String, CodingKey {
        case person = "self"
        case castId = "cast_id"
        case character
        case creditId = "credit_id"
        case order
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.castId = try container.decodeIfPresent(Int.self, forKey: .castId)
        self.character = try container.decodeIfPresent(String.self, forKey: .character)
        self.creditId = try container.decode(String.self, forKey: .creditId)
        self.order = try container.decodeIfPresent(Int.self, forKey: .order)

        self.person = try CreditsResponse.PersonCore(from: decoder)
    }
}


public struct CrewCredit: Codable, Hashable, Identifiable {
    public let person: CreditsResponse.PersonCore

    public let department: String?
    public let job: String?
    public let creditId: String

    public var id: String { creditId }

    enum CodingKeys: String, CodingKey {
            case department
            case job
            case creditId = "credit_id"
        }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.department = try container.decodeIfPresent(String.self, forKey: .department)
        self.job = try container.decodeIfPresent(String.self, forKey: .job)
        self.creditId = try container.decode(String.self, forKey: .creditId)

        self.person = try CreditsResponse.PersonCore(from: decoder)
    }
}
