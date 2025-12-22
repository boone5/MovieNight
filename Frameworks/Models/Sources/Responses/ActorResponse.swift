//
//  ActorResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

public struct ActorResponse: Codable {
    let cast: [Actor]?

    public struct Actor: Codable {
        public let id: Int
        public let adult: Bool?
        public let name: String?
        public let originalName: String?
        public let mediaType: String?
        public let popularity: Double?
        public let gender: Int?
        public let knownForDepartment: String?
        public let profilePath: String?
        public let character: String?
        
        public init(id: Int, adult: Bool?, name: String?, originalName: String?, mediaType: String?, popularity: Double?, gender: Int?, knownForDepartment: String?, profilePath: String?, character: String?) {
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
        }

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
        }
    }
}
