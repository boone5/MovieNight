//
//  ActorResponse.swift
//  MovieNight
//
//  Created by Boone on 3/14/24.
//

struct ActorResponse: Codable, Hashable, Identifiable {
    let id: Int64
    let adult: Bool?
    let name: String?
    let originalName: String?
    let mediaType: String?
    let popularity: Double?
    let gender: Int?
    let knownForDepartment: String??
    let profilePath: String?

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
    }
}
