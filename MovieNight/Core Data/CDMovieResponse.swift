//
//  CDMovieResponse.swift
//  MovieNight
//
//  Created by Boone on 10/30/23.
//

import CoreData

// source: https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/

//class CDMovieResponse: NSManagedObject, Decodable {
//    enum CodingKeys: CodingKey {
//        case page
//        case next
//        case entries
//        case results
//    }
//
//    required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.page = try container.decode(Int16.self, forKey: .page)
//        self.next = try container.decode(String.self, forKey: .next)
//        self.entries = try container.decode(Int16.self, forKey: .entries)
//        self.results = try container.decode(Set<CDMovieResult>.self, forKey: .results) as NSSet
//    }
//}
//
//extension CodingUserInfoKey {
//  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
//}
//
//enum DecoderConfigurationError: Error {
//  case missingManagedObjectContext
//}
