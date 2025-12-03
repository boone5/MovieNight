//
//  ActorResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

struct ActorResponse: Codable {
    let cast: [Actor]?

    struct Actor: Codable {
        let id: Int
        let adult: Bool?
        let name: String?
        let originalName: String?
        let mediaType: String?
        let popularity: Double?
        let gender: Int?
        let knownForDepartment: String?
        let profilePath: String?
        let character: String?

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

        var nameAdjusted: String {
            if let name {
                let split = name.split(separator: " ")
                return split.joined(separator: "\n")
            } else {
                return "-"
            }
        }
    }
}
