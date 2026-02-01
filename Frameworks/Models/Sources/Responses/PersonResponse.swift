//
//  ActorResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

public struct PersonResponse: Codable, Hashable, Identifiable {
    public let id: Int64
    public let adult: Bool?
    public let name: String
    public let originalName: String?
    public let mediaType: MediaType
    public let popularity: Double?
    public let gender: Gender?
    public let knownForDepartment: String?
    public let profilePath: String?
    public let character: String?
    public let knownFor: [MediaResult]?

    public var title: String { name }
    public var posterPath: String? { profilePath }
    public var overview: String? { nil }

    enum CodingKeys: String, CodingKey {
        case id
        case adult
        case name
        case originalName = "original_name"
        case mediaType = "media_type"
        case popularity
        case gender
        case knownForDepartment = "known_for_department"
        case profilePath = "profile_path"
        case character
        case knownFor = "known_for"
    }

    public init(id: Int64, adult: Bool?, name: String, originalName: String?, mediaType: MediaType, popularity: Double?, gender: Gender?, knownForDepartment: String?, profilePath: String?, character: String?, knownFor: [MediaResult]?) {
        self.id = id
        self.adult = adult
        self.name = name
        self.originalName = originalName
        self.mediaType = mediaType
        self.popularity = popularity
        self.gender = gender
        self.knownForDepartment = knownForDepartment
        self.profilePath = profilePath
        self.character = character
        self.knownFor = knownFor
    }
}

extension PersonResponse {
    public enum Gender: Int, Codable, Hashable {
        case notSpecified = 0
        case female = 1
        case male = 2
        case nonBinary = 3

        public var description: String {
            switch self {
            case .notSpecified: "Not Specified"
            case .female: "Female"
            case .male: "Male"
            case .nonBinary: "Non-binary"
            }
        }
    }
}
